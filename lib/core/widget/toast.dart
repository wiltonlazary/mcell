import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class Toast {
  static var position = StyledToastPosition(align: Alignment.bottomCenter, offset: 70.0);

  static info(String msg) => showToast(
        msg,
        backgroundColor: Color.fromARGB(255, 60, 150, 200),
        duration: Duration(seconds: 5),
        dismissOtherToast: true,
        position: position,
      );

  static success(String msg) => showToast(
        msg,
        backgroundColor: Color.fromARGB(255, 60, 200, 150),
        duration: Duration(seconds: 5),
        dismissOtherToast: true,
        position: position,
      );

  static warn(String msg) => showToast(
        msg,
        backgroundColor: Colors.yellow[700],
        duration: Duration(seconds: 5),
        dismissOtherToast: true,
        position: position,
      );

  static error(String msg) => showToast(
        msg,
        backgroundColor: Colors.red[900],
        duration: Duration(seconds: 5),
        dismissOtherToast: true,
        position: position,
      );

  static exception(e, [s]) {
    print("exception: ${e.runtimeType}");
    print(e);
    print(s);

    showToast(
      "Ops, ocorreu uma exceção.",
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 5),
      dismissOtherToast: true,
      position: position,
    );
  }
}
