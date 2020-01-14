import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../mcell.dart';
import '../theme.dart';
import 'loading.dart';
import 'util.dart';

class IconButtonCell extends StatefulWidget {
  IconButtonCell({
    Key key,
    this.icon,
    this.margin,
    this.focusEntry,
    this.onAction,
    this.cell,
    this.autofocus = false,
  }) : super(key: key);

  final Icon icon;
  final EdgeInsetsGeometry margin;
  final FocusEntry focusEntry;
  final OnAction onAction;
  final ModelCell cell;
  final bool autofocus;

  @override
  State<StatefulWidget> createState() => _IconButtonCellState();
}

class _IconButtonCellState extends State<IconButtonCell> {
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
    final size = widget.icon.size ?? 32.0;

    return Container(
      child: widget.cell != null && widget.cell.loading == lastActionTimestamp
          ? Loading(width: size, height: size)
          : Material(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              clipBehavior: Clip.antiAlias,
              color: colorTheme.basis.canvas,
              child: widget.onAction == null
                  ? Icon(
                      widget.icon.icon,
                      size: size,
                      color: colorTheme.basis.weak,
                    )
                  : InkWell(
                      child: widget.icon,
                      focusNode: subjectFocusNode,
                      onTap: () {
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
