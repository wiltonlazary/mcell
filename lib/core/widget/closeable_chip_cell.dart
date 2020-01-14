import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../mcell.dart';
import '../theme.dart';
import 'loading.dart';
import 'util.dart';

class CloseableChipCell extends StatefulWidget {
  CloseableChipCell({
    Key key,
    this.margin,
    this.constraints,
    this.focusEntry,
    this.onAction,
    this.cell,
    this.interest = "state",
    this.transin,
    this.label,
    this.autofocus = false,
  }) : super(key: key);

  final EdgeInsetsGeometry margin;
  final BoxConstraints constraints;
  final FocusEntry focusEntry;
  final OnAction onAction;
  final ModelCell cell;
  final String interest;
  final String label;
  final bool autofocus;
  final ModelTransformer<dynamic, dynamic> transin;

  @override
  State<StatefulWidget> createState() => _CloseableChipCellState();
}

class _CloseableChipCellState extends State<CloseableChipCell> {
  VoidCallback disposer;
  FocusNode subjectFocusNode;
  String _content;
  var lastActionTimestamp = -1;

  dynamic transformer(dynamic value) => widget.transin == null ? (value?.toString() ?? "") : widget.transin(value);

  @override
  initState() {
    super.initState();
    subjectFocusNode = widget.focusEntry == null ? FocusNode() : widget.focusEntry.node;
    _content = widget.cell.content(widget.interest, transformer: transformer);

    final unsubscribe = widget.cell == null
        ? null
        : widget.cell.subscribe(
            interests: [widget.interest, if (widget.interest != "loading") "loading"],
            onEvent: (event) {
              if (event.interest == widget.interest) {
                final content = transformer(event.payload);

                if (_content != content) {
                  setState(() {
                    _content = content;
                  });
                }
              } else {
                setState(() {/* Silent */});
              }
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
    final chipTheme = theme.chipTheme;
    final size = 28.0;
    final spacing = theme.spacing / 2;

    return Container(
      margin: widget.margin,
      constraints: widget.constraints,
      child: Row(
        children: <Widget>[
          Container(
            height: size,
            decoration: _content.isEmpty ? null : chipTheme.border,
            padding: EdgeInsets.only(left: spacing, top: 1.0, right: 1.0, bottom: 1.0),
            child: _content.isEmpty
                ? SizedBox(width: 20.0)
                : Row(
                    children: <Widget>[
                      Text(
                        "${widget.label == null ? "" : "${widget.label}: "}$_content",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: colorTheme.basis.normal,
                        ),
                      ),
                      SizedBox(width: spacing),
                      Container(
                        width: size * 0.8,
                        height: size * 0.8,
                        child: widget.cell != null && widget.cell.loading == lastActionTimestamp
                            ? Loading(width: size, height: size)
                            : Material(
                                shape: RoundedRectangleBorder(borderRadius: chipTheme.border.borderRadius),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  child: Icon(Icons.close, size: (size * 0.6).floorToDouble(), color: chipTheme.closeColor),
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
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
