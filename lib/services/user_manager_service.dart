import 'package:hive/hive.dart';
import '../core/remote.dart';

class UserManagerService {
  static Future<dynamic> fetch({String tid}) async {
    return await Remote.get("api/company/store/user/$tid");
  }

  static Future<dynamic> list(Map<dynamic, dynamic> params) async {
    return await Remote.get(
      "api/company/store/user",
      data: params,
    );
  }

  static Future<dynamic> save(String tid, Map<dynamic, dynamic> data) async {
    return await ((tid == "_") ? Remote.post("api/company/store/user", data: data) : Remote.put("api/company/store/user/$tid", data: data));
  }

  static Future<dynamic> delete(String tid) async {
    return await (Remote.delete("api/company/store/user/$tid"));
  }
}
