import 'package:dio/dio.dart';
import 'package:to_do/core/storage/token_manage.dart';
import 'package:to_do/features/auth/data/data_source/auth_data_remote.dart';
import 'package:to_do/features/auth/presentation/bloc/auth_state_manager.dart';

class AuthInterceptor extends Interceptor {
  final AuthDataRemote dataRemote;
  final TokenManage manager;
  final AuthStateManager stateManager;
  final Dio retryClient; // không gắn AuthInterceptor
  final Dio refreshClient; // không gắn AuthInterceptor

  AuthInterceptor({
    required this.dataRemote,
    required this.manager,
    required this.stateManager,
    required this.retryClient,
    required this.refreshClient,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = manager.getToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshRequest(err.requestOptions)) {
      final refreshToken = manager.getRefreshToken();
      if (refreshToken == null) {
        stateManager.setLoggedOut();
        return handler.reject(err);
      }

      try {
        // dùng refreshClient để tránh loop
        final newAccessToken = await dataRemote.refreshAccessToken(refreshToken);

        await manager.saveToken(newAccessToken);

        final retryOptions = Options(
          method: err.requestOptions.method,
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $newAccessToken',
          },
          contentType: err.requestOptions.contentType,
          responseType: err.requestOptions.responseType,
        );

        final response = await retryClient.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: retryOptions,
        );

        return handler.resolve(response);
      } catch (e) {
        stateManager.setLoggedOut();
        return handler.reject(err);
      }
    }
    handler.next(err);
  }

  bool _isRefreshRequest(RequestOptions options) {
    // tránh intercept chính request refresh token
    return options.path.contains('/refresh-token');
  }
}
