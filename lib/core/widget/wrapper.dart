import 'package:flutter/material.dart';
import '../mcell.dart';
import '../theme.dart';

Widget entryWrapper({
  BuildContext context,
  EdgeInsetsGeometry margin,
  BoxConstraints constraints,
  CoreTheme theme,
  List<ModelConstraintValidationResult> errors,
  String label,
  FocusNode subjectFocusNode,
  bool enabled,
  bool isEmpty,
  Widget subjectBuilder(),
}) {
  final colorTheme = theme.colorTheme;
  final entryTheme = theme.entryTheme;
  final hasErros = errors.isNotEmpty;
  BoxDecoration decoration;
  Color labelColor;
  Color constraintColor;

  if (!enabled) {
    decoration = hasErros ? entryTheme.disabledBorderError : entryTheme.disabledBorder;
    labelColor = hasErros ? entryTheme.labelEntryColor.disabledError : entryTheme.labelEntryColor.disabled;
    constraintColor = hasErros ? entryTheme.errorEntryColor.disabledError : entryTheme.errorEntryColor.disabled;
  } else if (subjectFocusNode.hasFocus) {
    decoration = hasErros ? entryTheme.focusedBorderError : entryTheme.focusedBorder;
    labelColor = hasErros ? entryTheme.labelEntryColor.focusedError : entryTheme.labelEntryColor.focused;
    constraintColor = hasErros ? entryTheme.errorEntryColor.focusedError : entryTheme.errorEntryColor.focused;
  } else {
    decoration = hasErros ? entryTheme.enabledBorderError : entryTheme.enabledBorder;
    labelColor = hasErros ? entryTheme.labelEntryColor.enabledError : entryTheme.labelEntryColor.enabled;
    constraintColor = hasErros ? entryTheme.errorEntryColor.enabledError : entryTheme.errorEntryColor.enabled;
  }

  final subject = subjectBuilder();

  return Container(
    constraints: constraints,
    margin: margin,
    height: entryTheme.height,
    color: colorTheme.basis.canvas,
    child: Stack(
      children: <Widget>[
        !hasErros
            ? Container()
            : Positioned(
                top: entryTheme.errorTop,
                left: entryTheme.errorLeft,
                child: Container(
                  height: entryTheme.errorHeight,
                  decoration: BoxDecoration(
                    color: colorTheme.basis.canvas,
                  ),
                  child: label == null
                      ? null
                      : Padding(
                          padding: entryTheme.errorPadding,
                          child: Text(
                            errors.first.message.short,
                            style: TextStyle(
                              fontFamily: entryTheme.labelFontFamily,
                              fontSize: entryTheme.errorFontSize,
                              fontWeight: entryTheme.errorFontWeight,
                              color: constraintColor,
                            ),
                          ),
                        ),
                ),
              ),
        Container(
          margin: EdgeInsets.fromLTRB(entryTheme.borderXAdjust, entryTheme.borderTop, entryTheme.borderXAdjust, 0),
          decoration: decoration,
          height: entryTheme.entryHeight,
          width: double.infinity,
        ),
        Container(
          margin: EdgeInsets.fromLTRB(entryTheme.borderXAdjust, entryTheme.entryTop, entryTheme.borderXAdjust, 0),
          padding: entryTheme.entryPadding,
          height: entryTheme.entryHeight,
          width: double.infinity,
          child: subject,
        ),
        if (subjectFocusNode.hasFocus || !isEmpty)
          Positioned(
            left: entryTheme.labelLeft,
            top: entryTheme.labelTop,
            child: IgnorePointer(
              child: Container(
                height: entryTheme.lebelHeight,
                decoration: BoxDecoration(
                  color: colorTheme.basis.canvas,
                ),
                child: label == null
                    ? null
                    : Padding(
                        padding: entryTheme.labelPadding,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: entryTheme.labelFontFamily,
                            fontSize: entryTheme.labelFontSize,
                            fontWeight: entryTheme.labelFontWeight,
                            color: labelColor,
                          ),
                        ),
                      ),
              ),
            ),
          ),
      ],
    ),
  );
}
