import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const MethodChannel pluginChannel = kIsWeb ? MethodChannel('plugins.flutter.io/laz_flutter_web') : null;
