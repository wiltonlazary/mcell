import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class Persistence {
  static Box _storage;

  static init() async {
    if (!kIsWeb) {
      Hive.init((await getApplicationDocumentsDirectory()).path);
    }

    _storage = await Hive.openBox('main');
  }

  static Future<void> put(dynamic key, dynamic value) async {
    return await _storage.put(key, value);
  }

  static Future<dynamic> get(dynamic key) async {
    return await _storage.get(key);
  }
}
