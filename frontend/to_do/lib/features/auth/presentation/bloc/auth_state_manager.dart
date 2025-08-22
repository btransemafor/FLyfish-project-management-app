import 'dart:async';

class AuthStateManager {
  final _authStateController = StreamController<bool>.broadcast();
  
  Stream<bool> get authStateStream => _authStateController.stream;

  void setLoggedIn() => _authStateController.add(true);
  void setLoggedOut() => _authStateController.add(false);

  void dispose() {
    _authStateController.close();
  }
}
