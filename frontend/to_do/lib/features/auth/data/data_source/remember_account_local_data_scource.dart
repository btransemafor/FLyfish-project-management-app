import 'package:hive/hive.dart';
import 'package:to_do/core/boxes.dart';
abstract class RememberAccountLocalDataScource {
  Future<void> rememberMe(String password, String email);
  Future<Map<String,String>> getRemember(); 
  
}

class RememberAccountLocalDataSourceImpl implements RememberAccountLocalDataScource {
  final Box<Map<String, String>> accountBox ; 
  const RememberAccountLocalDataSourceImpl(this.accountBox); 
  @override
  Future<void> rememberMe(String password, String email) async {
    await accountBox.put('account', {"password": password, "email": email}); 
  }
  @override
    Future<Map<String, String>> getRemember() async {
      final data = accountBox.get('account');
      if (data is Map<String, String>) {
        return data;
      } else {
        return {};
      }
    }
}