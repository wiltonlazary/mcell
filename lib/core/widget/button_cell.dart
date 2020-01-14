import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../mcell.dart';
import '../theme.dart';
import 'loading.dart';
import 'util.dart';

enum ButtonPrecedence {
  primary,
  secondary,
}

class ButtonCell extends StatefulWidget {
  ButtonCell({
    Key key,
    this.label,
    this.margin,
    this.constraints,
    this.focusEntry,
    this.onAction,
    this.cell,
    this.autofocus = false,
    this.precedence = ButtonPrecedence.primary,
  }) : super(key: key);

  final String label;
  final EdgeInsetsGeometry margin;
  final BoxConstraints constraints;
  final FocusEntry focusEntry;
  final OnAction onAction;
  final ModelCell cell;
  final bool autofocus;
  final ButtonPrecedence precedence;

  @override
  State<StatefulWidget> createState() => _ButtonCellState();
}

class _ButtonCellState extends State<ButtonCell> {
  VoidCallback disposer;
  FocusNode subjectFocusNode;
  var lastActionTimestamp = -1;

  @override
  initState() {
    super.initState();
    subjectFocusNode = widget.focusEntry == null ? FocusNode() : widget.focusEntry.node;

    final unsubscribe = widget.cell == null
        ? null
        : widget.cell.subscribe(
            interests: ["loading"],
            onEvent: (event) {
              setState(() {
                //Silent
              });
            },
          );

    final focusCallback = () {
      setState(() {/* Silent */});
    };

    subjectFocusNode.addListener(focusCallback);

    disposer = () {
      if (unsubscribe != null) {
        unsubscribe();
      }

      subjectFocusNode.removeListener(focusCallback);
    };
  }

  @override
  void dispose() {
    if (disposer != null) disposer();

    if (widget.focusEntry == null) {
      subjectFocusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;
    final buttonTheme = theme.buttonTheme;

    final text = Text(
      widget.label,
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: subjectFocusNode.hasFocus
            ? (widget.precedence == ButtonPrecedence.primary ? colorTheme.secondary.accent : colorTheme.secondary.canvasFace)
            : (widget.precedence == ButtonPrecedence.primary ? colorTheme.primary.canvasFace : colorTheme.secondary.canvasFace),
      ),
    );

    final child = widget.cell != null && widget.cell.loading == lastActionTimestamp
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Loading(width: 32.0, height: 32.0),
              Container(
                margin: EdgeInsets.only(right: 32.0),
                child: text,
              ),
            ],
          )
        : text;

    return Container(
      margin: widget.margin,
      constraints: widget.constraints,
      height: buttonTheme.height,
      child: Material(
        shape: (widget.precedence == ButtonPrecedence.primary ? buttonTheme.primaryShape : buttonTheme.secondaryShape),
        clipBehavior: Clip.antiAlias,
        color: subjectFocusNode.hasFocus
            ? (widget.precedence == ButtonPrecedence.primary ? colorTheme.primary.accent : colorTheme.secondary.accent)
            : (widget.precedence == ButtonPrecedence.primary ? colorTheme.primary.canvas : colorTheme.secondary.canvas),
        child: InkWell(
          hoverColor: widget.precedence == ButtonPrecedence.primary ? colorTheme.primary.accent : colorTheme.secondary.accent,
          child: Center(
            child: child,
          ),
          focusNode: subjectFocusNode,
          onTap: () {
            FocusScope.of(context).requestFocus(subjectFocusNode);

            if (widget.onAction != null && (widget.cell == null || widget.cell.loading == 0)) {
              lastActionTimestamp = DateTime.now().millisecondsSinceEpoch;

              Future.microtask(() {
                widget.onAction(lastActionTimestamp);
              });
            }
          },
        ),
      ),
    );
  }
}
