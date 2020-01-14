import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Link extends StatelessWidget {
  const Link({
    Key key,
    this.label,
    this.onAction,
    this.margin,
    this.constraints,
  }) : super(key: key);

  final String label;
  final VoidCallback onAction;
  final EdgeInsetsGeometry margin;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      constraints: constraints ?? BoxConstraints(minHeight: 32.0),
      child: InkWell(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label, style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
        ),
        onTap: onAction,
      ),
    );
  }
}
