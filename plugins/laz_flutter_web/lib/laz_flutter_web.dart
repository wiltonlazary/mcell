@JS()
library main;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';

@JS()
external global();

@JS()
external setLocationHash(String hash);

class LazFlutterWebPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel('plugins.flutter.io/laz_flutter_web', const StandardMethodCodec(), registrar.messenger);
    final LazFlutterWebPlugin instance = LazFlutterWebPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'hash':
        final String hash = call.arguments;
        setLocationHash(hash);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The laz_flutter_web plugin for web doesn't implement the method '${call.method}'",
        );
    }
  }
}
