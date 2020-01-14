import 'package:flutter/material.dart';
import '../theme.dart';

/*
   Container(
            margin: theme.edgeInsets,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 0.8),
              borderRadius: BorderRadius.circular(10.0),
            )
 */
@immutable
class CardContainer extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  CardContainer({this.child, this.elevation, this.margin, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final cardTheme = CoreTheme.of(context).cardContainerTheme;

    return Container(
      margin: margin ?? theme.margin,
      padding: padding ?? theme.margin,
      child: child,
    );
  }
}
