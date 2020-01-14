import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'persistence.dart';
import 'lang/lang.dart';

String paramsToString(Map<dynamic, dynamic> params) =>
    params.transform((key, value) => "${Uri.encodeComponent(key.toString())}=${Uri.encodeComponent(value.toString())}").join("&");

class RemoteException implements Exception {
  final int code;
  final content;
  RemoteException(this.code, this.content);

  @override
  String toString() => content.toString();
}

class UnknownRemoteException extends RemoteException {
  UnknownRemoteException(int code, content) : super(code, content);
}

class UnauthorizedRemoteException extends RemoteException {
  UnauthorizedRemoteException([int code, content]) : super(code, content);
}

class InternalRemoteException extends RemoteException {
  InternalRemoteException(int code, content) : super(code, content);
}

class ValidationRemoteException extends RemoteException {
  ValidationRemoteException(int code, content) : super(code, content);

  Map<String, List<dynamic>> get fields => Map.fromIterable(content["fields"].entries, key: (it) => it.key, value: (it) => [it.value]);
}

class DuplicatedEntryRemoteException extends RemoteException {
  DuplicatedEntryRemoteException(int code, content) : super(code, content);
}

class RemoteConnectionException extends RemoteException {
  RemoteConnectionException(int code, content) : super(code, content);
}

//duplicate key value violates unique constraint

/* 
class AsyncIntegrationException : RuntimeException()

class InternalException(protocol: ApiProtocol) : ApiProtocolException(protocol)

open class ValidationException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class DuplicatedException(protocol: ApiProtocol) : ValidationException(protocol)

class PayloadValidationException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class NotFoundException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class AuthException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class OptimisticUpdateException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class FetchException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class BadRequestException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class UnprocessableEntityException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class ForbiddenException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class IntegrationException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class TransactionException(protocol: ApiProtocol) : ApiProtocolException(protocol)

class LockException(protocol: ApiProtocol) : ApiProtocolException(protocol)
*/

class Remote {
  static String token;
  static String storeToken;
  static final encoding = Encoding.getByName("utf-8");
  static var base = 'https://api-erp-dev.hail-hydra.com.br';
  // static var base = 'http://10.173.70.25:8085';
  static var defaultHeaders = {"Content-Type": "application/json", "Accept": "application/json"};

  static _fillStoreToken() {
    storeToken = (token == null) ? null : token.split("-")[2];
  }

  static init() async {
    token = await Persistence.get('token');
    _fillStoreToken();
  }

  static Future<void> setToken(String value) async {
    token = value;
    _fillStoreToken();
    return await Persistence.put('token', value);
  }

  static Future<dynamic> _processResult(result, [int statusCode]) async {
    final code = statusCode ?? result["code"];
    print("code: $code");

    if (code == 200) {
      return json.decode(result);
    } else if (code >= 500) {
      throw InternalRemoteException(code, result);
    } else {
      switch (code) {
        case 401:
          print("Unauthorized: 401");
          await Remote.setToken(null);
          await Persistence.put('self', null);
          throw UnauthorizedRemoteException(code, result);
          break;
        case 409:
          throw DuplicatedEntryRemoteException(code, json.decode(result));
          break;
        case 417:
          final content = json.decode(result);

          if (content["error"]["message"]?.startsWith("duplicate key value violates unique constraint") ?? false) {
            throw DuplicatedEntryRemoteException(code, content);
          } else {
            throw UnknownRemoteException(code, json.decode(result));
          }
          break;
        case 425:
          throw ValidationRemoteException(code, json.decode(result));
          break;
        default:
          throw UnknownRemoteException(code, json.decode(result));
      }
    }
  }

  static dynamic _buildHeaders(Map<String, String> headers) {
    return {
      ...defaultHeaders,
      if (headers != null) ...headers,
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static dynamic _buildDeleteHeaders(Map<String, String> headers) {
    return {
      if (headers != null) ...headers,
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<dynamic> get(String uri, {Map<dynamic, dynamic> data, Map<String, String> headers}) async {
    var response;

    try {
      response = await http.get(
        data == null ? "$base/$uri" : "$base/$uri?${paramsToString(data)}",
        headers: _buildHeaders(headers),
      );
    } on SocketException catch (e) {
      throw RemoteConnectionException(0, e);
    } catch (e) {
      if (e.message == "XMLHttpRequest error.") {
        throw RemoteConnectionException(0, e);
      } else {
        throw e;
      }
    }

    return await _processResult(response.body, response.statusCode);
  }

  static Future<dynamic> post(String uri, {Map<dynamic, dynamic> data, Map<String, String> headers}) async {
    var response;

    try {
      response = await http.post(
        "$base/$uri",
        headers: _buildHeaders(headers),
        encoding: encoding,
        body: json.encode(data ?? {}),
      );
    } on SocketException catch (e) {
      throw RemoteConnectionException(0, e);
    } catch (e) {
      if (e.message == "XMLHttpRequest error.") {
        throw RemoteConnectionException(0, e);
      } else {
        throw e;
      }
    }

    return await _processResult(response.body, response.statusCode);
  }

  static Future<dynamic> put(String uri, {Map<dynamic, dynamic> data, Map<String, String> headers}) async {
    var response;

    try {
      response = await http.put(
        "$base/$uri",
        headers: _buildHeaders(headers),
        encoding: encoding,
        body: json.encode(data ?? {}),
      );
    } on SocketException catch (e) {
      throw RemoteConnectionException(0, e);
    } catch (e) {
      if (e.message == "XMLHttpRequest error.") {
        throw RemoteConnectionException(0, e);
      } else {
        throw e;
      }
    }

    return await _processResult(response.body, response.statusCode);
  }

  static Future<dynamic> delete(String uri, {Map<dynamic, dynamic> data, Map<String, String> headers}) async {
    var response;

    try {
      response = await http.delete(
        "$base/$uri",
        headers: _buildDeleteHeaders(headers),
      );
    } on SocketException catch (e) {
      throw RemoteConnectionException(0, e);
    } catch (e) {
      if (e.message == "XMLHttpRequest error.") {
        throw RemoteConnectionException(0, e);
      } else {
        throw e;
      }
    }

    return await _processResult(response.body, response.statusCode);
  }
}
