import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../mcell.dart';
import '../theme.dart';
import 'combo_menu.dart';
import 'util.dart';
import 'wrapper.dart';

class ComboCell extends StatefulWidget {
  ComboCell({
    Key key,
    this.cell,
    this.mask,
    this.transin,
    this.transout,
    this.hintText,
    this.label,
    this.margin,
    this.constraints,
    this.focusEntry,
    this.enabled = true,
    this.selectedItemBuilder,
    this.itemBuilder,
  }) : super(key: key);

  final ModelCell cell;
  final dynamic mask;
  final ModelTransformer<dynamic, dynamic> transin;
  final ModelTransformer<dynamic, dynamic> transout;
  final String hintText;
  final String label;
  final EdgeInsetsGeometry margin;
  final BoxConstraints constraints;
  final FocusEntry focusEntry;
  final bool enabled;
  final DropdownButtonBuilder selectedItemBuilder;
  final DropdownButtonBuilder itemBuilder;

  @override
  State<StatefulWidget> createState() => _ComboCellState();
}

class _ComboCellState extends State<ComboCell> {
  VoidCallback disposer;
  List<ModelConstraintValidationResult> errors;
  FocusNode subjectFocusNode;
  dynamic dropdownValue;
  dynamic dropdownState;

  @override
  initState() {
    super.initState();
    errors = widget.cell.errors;
    subjectFocusNode = widget.focusEntry == null ? FocusNode() : widget.focusEntry.node;
    dynamic getCellValue(dynamic value) => widget.transin == null ? value : widget.transin(value);
    dropdownValue = getCellValue(widget.cell.value);
    dropdownState = widget.cell.state;

    final unsubscribe = widget.cell.subscribe(
      interests: ["value", "state", "errors"],
      onEvent: (event) {
        print("event: ${event.interest} / ${event.payload}");

        switch (event.interest) {
          case "value":
            final value = getCellValue(event.payload);

            if (value != dropdownValue) {
              setState(() {
                dropdownValue = value;
              });
            }
            break;
          case "state":
            setState(() {
              dropdownState = event.payload;
            });
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

    final focusCallback = () {
      setState(() {/* Silent */});
    };

    subjectFocusNode.addListener(focusCallback);

    disposer = () {
      unsubscribe();
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

  _onChanged(dynamic value) {
    widget.cell.value = widget.transout == null ? value : widget.transout(value);
    widget.cell.validate();
  }

  bool _isEmpty() => dropdownValue == null;

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final entryTheme = theme.entryTheme;
    final isEmpty = _isEmpty();

    return entryWrapper(
      context: context,
      margin: widget.margin,
      constraints: widget.constraints,
      theme: theme,
      errors: errors,
      label: widget.label,
      subjectFocusNode: subjectFocusNode,
      enabled: widget.enabled,
      isEmpty: isEmpty,
      subjectBuilder: () {
        return ComboMenuButton(
          offset: Offset(0, 0),
          enabled: widget.enabled,
          onSelected: _onChanged,
          initialValue: dropdownValue,
          itemBuilder: (context) => dropdownState.entries
              .map<ComboMenuItem>(
                (entry) => ComboMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontFamily: entryTheme.entryFontFamily,
                      fontSize: entryTheme.entryFontSize,
                      fontWeight: entryTheme.entryFontWeight,
                    ),
                  ),
                ),
              )
              .toList(),
          childBuilder: (context, showmenu) => InkWell(
            focusNode: subjectFocusNode,
            onTap: () {
              FocusScope.of(context).requestFocus(subjectFocusNode);
              showmenu();
            },
            onLongPress: () {
              FocusScope.of(context).requestFocus(subjectFocusNode);
            },
            child: Container(
              width: double.infinity,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      dropdownState[dropdownValue],
                      style: TextStyle(
                        fontFamily: entryTheme.entryFontFamily,
                        fontSize: entryTheme.entryFontSize,
                        fontWeight: entryTheme.entryFontWeight,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    size: entryTheme.iconSize,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
