import 'package:dio/dio.dart';
import 'package:to_do/core/storage/token_manage.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state_manager.dart';
import 'package:to_do/injection.dart';
// Import thêm cho Completer
import 'dart:async';
class DioClient {
  final Dio dio;
  final Dio refreshDio;
  final AuthStateManager authStateManager;

  // Instance variables cho interceptor state
  bool _isRefreshing = false;
  final List<Completer<String?>> _requestQueue = [];

  DioClient({
    String baseUrl = 'http://192.168.1.5:5000/api',
    required this.authStateManager,
  })  : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        )),
        refreshDio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _addInterceptors();
  }

  void _addInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final accessToken = getIt<TokenManage>().getToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          await _handleError(error, handler);
        },
      ),
    );
  }

  Future<void> _handleError(DioException error, ErrorInterceptorHandler handler) async {
    final requestOptions = error.requestOptions;
    
    // Nếu refresh token endpoint trả về lỗi => logout ngay
    if (requestOptions.path.contains('/auth/request-new-accessToken')) {
      print('Refresh token endpoint failed: ${error.response?.data}');
      await _performLogout();
      return handler.reject(error);
    }

    // Xử lý lỗi 401 - Unauthorized
    if (error.response?.statusCode == 401 && 
        requestOptions.extra['retried'] != true) {
      
      final newToken = await _handleTokenRefresh();
      
      if (newToken != null && newToken.isNotEmpty) {
        // Retry request với token mới
        try {
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          requestOptions.extra['retried'] = true;
          
          final cloneResponse = await dio.fetch(requestOptions);
          return handler.resolve(cloneResponse);
        } catch (retryError) {
          print('Retry request failed: $retryError');
          return handler.reject(error);
        }
      } else {
        // Refresh thất bại => logout
        await _performLogout();
        return handler.reject(error);
      }
    }

    // Xử lý các lỗi khác hoặc 401 đã retry
    if (error.response?.statusCode == 403) {
      await _performLogout();
    }
    
    return handler.reject(error);
  }

  Future<String?> _handleTokenRefresh() async {
    // Nếu đang refresh, chờ kết quả
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _requestQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;
    String? newToken;
    
    try {
      newToken = await _refreshAccessToken();
      
      if (newToken != null && newToken.isNotEmpty) {
        // Lưu token mới
        await getIt<TokenManage>().saveToken(newToken);
        
        // Resolve tất cả requests đang chờ
        for (final completer in _requestQueue) {
          if (!completer.isCompleted) {
            completer.complete(newToken);
          }
        }
      } else {
        // Reject tất cả requests đang chờ
        for (final completer in _requestQueue) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        }
      }
    } catch (e) {
      print('Token refresh error: $e');
      // Reject tất cả requests đang chờ
      for (final completer in _requestQueue) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    } finally {
      _isRefreshing = false;
      _requestQueue.clear();
    }
    
    return newToken;
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = getIt<TokenManage>().getRefreshToken();
      
      if (refreshToken == null || refreshToken.isEmpty) {
        print('No refresh token available');
        return null;
      }

      print('Attempting token refresh with token: ${refreshToken.substring(0, 20)}...');
      final response = await refreshDio.post(
        '/auth/request-new-accessToken',
        data: {'refreshToken': refreshToken},
      );

      print('Refresh response: ${response.data}');
      
      // Kiểm tra success field trước
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        
        // Kiểm tra success field
        if (data['success'] == false) {
          print('Refresh failed on server: ${data['message']}');
          return null;
        }
        
        // Trích xuất token mới
        return data['data']?.toString() ?? 
               data['accessToken']?.toString() ?? 
               data['access_token']?.toString();
      } else if (response.data is String) {
        return response.data as String;
      }
      
      return null;
    } catch (e) {
      print('Refresh token failed: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        
        // Nếu 403 hoặc 401 => refresh token đã expired
        if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
          print('Refresh token expired, forcing logout');
          _performLogout();
        }
      }
      rethrow; // Throw lại để _handleTokenRefresh có thể xử lý
    }
  }

  Future<void> _performLogout() async {
    try {
      print('Performing logout - clearing all tokens');
      await getIt<TokenManage>().clearToken();
      authStateManager.setLoggedOut();
      print('User logged out due to authentication failure');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Method để kiểm tra token validity trước khi dùng
  Future<bool> isTokenValid() async {
    final token = getIt<TokenManage>().getToken();
    final refreshToken = getIt<TokenManage>().getRefreshToken();
    
    if (token == null || refreshToken == null) {
      return false;
    }
    
    // Có thể thêm logic kiểm tra expiry time nếu có
    return true;
  }

  // Method để force refresh token (dùng khi cần)
  Future<bool> forceRefreshToken() async {
    try {
      final newToken = await _refreshAccessToken();
      if (newToken != null && newToken.isNotEmpty) {
        await getIt<TokenManage>().saveToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      print('Force refresh failed: $e');
      await _performLogout();
      return false;
    }
  }

  // Method để cleanup khi dispose
  void dispose() {
    dio.close();
    refreshDio.close();
  }
}

