// core/hive/hive_service.dart
import 'package:hive/hive.dart';

class HiveService {
  Future<void> init() async {
    // Initialize Hive, register adapters
  }

  Box<T> openBox<T>(String boxName) {
    return Hive.box<T>(boxName);
  }
}
