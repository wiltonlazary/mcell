import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/remote.dart';
import 'user_service.dart';

class LoginService {
  static login(String email, String password) async {
    final result = await Remote.post(
      "api/ref/auth/login",
      data: {
        "authType": "STORE",
        "provider": "localSecured",
        "email": email,
      },
      headers: {
        "X-SECURED": base64.encode(utf8.encode(json.encode({"password": sha256.convert(utf8.encode(password)).toString()})))
      },
    );

    if (Remote.token != null) {
      await logout();
    }

    print("token: ${result["data"]["token"]}");
    await Remote.setToken(result["data"]["bearer"]);
    await UserService.self();
  }

  static Future<void> logout() async {
    print("logout");

    try {
      await Remote.post("api/ref/user/self/logout");
    } catch (e) {
      print(e);
    } finally {
      try {
        await UserService.clearSelf();
        await Remote.setToken(null);
      } catch (e) {
        print(e);
      }
    }
  }
}
