import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../mcell.dart';
import '../theme.dart';
import 'util.dart';

class CheckboxCell extends StatefulWidget {
  CheckboxCell({
    Key key,
    this.cell,
    this.transin,
    this.transout,
    this.margin,
    this.constraints,
    this.focusEntry,
    this.enabled = true,
  }) : super(key: key);

  final ModelCell cell;
  final ModelTransformer<dynamic, dynamic> transin;
  final ModelTransformer<dynamic, dynamic> transout;
  final EdgeInsetsGeometry margin;
  final BoxConstraints constraints;
  final FocusEntry focusEntry;
  final bool enabled;

  @override
  State<StatefulWidget> createState() => _CheckboxCellState();
}

class _CheckboxCellState extends State<CheckboxCell> {
  VoidCallback disposer;
  List<ModelConstraintValidationResult> errors;
  FocusNode subjectFocusNode;
  dynamic subjectValue;

  @override
  initState() {
    super.initState();
    errors = widget.cell.errors;
    subjectFocusNode = widget.focusEntry == null ? FocusNode() : widget.focusEntry.node;
    dynamic getCellValue(dynamic value) => widget.transin == null ? (value ?? false) : widget.transin(value);
    subjectValue = getCellValue(widget.cell.value);

    final unsubscribe = widget.cell.subscribe(
      interests: ["value", "errors"],
      onEvent: (event) {
        switch (event.interest) {
          case "value":
            final value = getCellValue(event.payload);

            if (value != subjectValue) {
              setState(() {
                subjectValue = value;
              });
            }
            break;
          case "errors":
            if (event.payload.isNotEmpty || errors.isNotEmpty) {
              setState(() {
                errors = event.payload;
              });
            }
            break;
        }
      },
    );

    disposer = () {
      unsubscribe();
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

  _onChanged(bool value) {
    widget.cell.value = widget.transout == null ? value : widget.transout(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final switchTheme = theme.switchTheme;
    final colorTheme = theme.colorTheme;

    return Container(
      margin: widget.margin == null
          ? null
          : widget.margin.add(EdgeInsets.fromLTRB(switchTheme.marginCompensation, 0, switchTheme.marginCompensation, 0)),
      constraints: widget.constraints,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onLongPress: () {
              FocusScope.of(context).requestFocus(subjectFocusNode);
            },
            child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              focusNode: subjectFocusNode,
              onChanged: (value) {
                FocusScope.of(context).requestFocus(subjectFocusNode);
                _onChanged(value);
              },
              value: subjectValue,
              activeColor: colorTheme.primary.canvas,
              checkColor: colorTheme.primary.canvasFace,
            ),
          ),
        ],
      ),
    );
  }
}
