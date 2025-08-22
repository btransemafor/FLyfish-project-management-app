// lib/core/socket/socket_manager.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:to_do/core/storage/token_manage.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;

  IO.Socket? _socket;
  bool _isInitialized = false;
  final TokenManage _tokenManage = TokenManage();

  SocketManager._internal();

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Ensure TokenManage is initialized
    await _tokenManage.init();
    
    final token = _tokenManage.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    _socket = IO.io(
      'http://192.168.1.5:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setQuery({'token': 'Bearer $token'}) // Use actual token
          .build(),
    );

    _socket!.connect();
    _isInitialized = true;

    // Optional: Add connection event listeners
    _socket!.on('connect', (_) {
      print('Socket connected successfully');
    });

    _socket!.on('disconnect', (_) {
      print('Socket disconnected');
    });

    _socket!.on('connect_error', (error) {
      print('Socket connection error: $error');
    });
  }

  IO.Socket? getSocket() {
    if (!_isInitialized || _socket == null) {
      throw Exception('SocketManager not initialized. Call init() first.');
    }
    return _socket;
  }

  bool get isConnected => _socket?.connected ?? false;
  bool get isInitialized => _isInitialized;

  void disconnect() {
    _socket?.disconnect();
    _isInitialized = false;
  }

  Future<void> reconnectWithNewToken() async {
    disconnect();
    _isInitialized = false;
    await init();
  }
}