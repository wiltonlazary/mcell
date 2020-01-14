import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../mcell.dart';
import '../theme.dart';
import 'loading.dart';
import 'util.dart';
import 'wrapper.dart';

class DecimalMask {
  DecimalMask({
    this.decimalSeparator = ',',
    this.thousandSeparator = '.',
    this.rightSymbol = '',
    this.leftSymbol = '',
    this.precision = 2,
  });

  static final localized = DecimalMask();
  final String decimalSeparator;
  final String thousandSeparator;
  final String rightSymbol;
  final String leftSymbol;
  final int precision;
}

typedef dynamic _GetControllerValue();

typedef _SetControllerValue(dynamic value);

class TextEntryCell extends StatefulWidget {
  TextEntryCell({
    Key key,
    this.cell,
    this.label,
    this.mask,
    this.transin,
    this.transout,
    this.hintText,
    this.margin,
    this.constraints,
    this.focusEntry,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.keyboardAppearance,
    this.autofocus = false,
    this.icon,
    this.onAction,
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
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final Brightness keyboardAppearance;
  final bool autofocus;
  final Icon icon;
  final OnAction onAction;

  @override
  State<StatefulWidget> createState() => _TextEntryCellState();
}

class _TextEntryCellState extends State<TextEntryCell> {
  VoidCallback disposer;
  List<ModelConstraintValidationResult> errors;
  TextEditingController controller;
  FocusNode subjectFocusNode;
  _GetControllerValue getControllerValue;
  _SetControllerValue setControllerValue;
  int lastActionTimestamp = -1;
  Icon localIcon;
  bool localObscureText;
  OnAction localOnAction;

  dynamic getCellValue(dynamic value) => widget.transin == null ? (value?.toString() ?? "") : widget.transin(value);

  @override
  initState() {
    localObscureText = widget.obscureText;
    localIcon = widget.icon;
    localOnAction = widget.onAction;

    if (widget.obscureText && widget.icon == null) {
      final colorTheme = CoreTheme.of(context).colorTheme;
      localIcon = Icon(FontAwesomeIcons.eyeSlash, color: colorTheme.primary.canvas);
    }

    if (widget.obscureText && widget.onAction == null) {
      localOnAction = (int timestamp) {
        setState(() {
          final colorTheme = CoreTheme.of(context).colorTheme;

          if (localObscureText) {
            localObscureText = false;
            localIcon = Icon(FontAwesomeIcons.eye, color: colorTheme.primary.canvas);
          } else {
            localObscureText = true;
            localIcon = Icon(FontAwesomeIcons.eyeSlash, color: colorTheme.primary.canvas);
          }
        });
      };
    }

    super.initState();
    errors = widget.cell.errors;
    subjectFocusNode = widget.focusEntry == null ? FocusNode() : widget.focusEntry.node;

    {
      var localValue = getCellValue(widget.cell.value);

      if (!widget.enabled) {
        getControllerValue = () => localValue;
        setControllerValue = (it) => setState(() => localValue = it);
      } else if (widget.mask == null) {
        controller = TextEditingController.fromValue(TextEditingValue(text: localValue));
        getControllerValue = () => controller.text;
        setControllerValue = (it) => controller.text = it;
      } else if (widget.mask is DecimalMask) {
        final mask = widget.mask as DecimalMask;
        var initialValue = 0.0;

        if (localValue == null) {
          initialValue = 0.0;
        } else if (localValue is num) {
          initialValue = localValue;
        } else {
          final strValue = localValue.toString();
          initialValue = strValue.isEmpty ? 0.0 : double.parse(strValue);
        }

        final maskedController = MoneyMaskedTextController(
            initialValue: initialValue,
            decimalSeparator: mask.decimalSeparator,
            thousandSeparator: mask.thousandSeparator,
            rightSymbol: mask.rightSymbol,
            leftSymbol: mask.leftSymbol,
            precision: mask.precision);

        controller = maskedController;
        getControllerValue = () => maskedController.numberValue;
        setControllerValue = (it) => maskedController.updateValue(it);
      } else {
        controller = MaskedTextController(text: localValue, mask: widget.mask);
        getControllerValue = () => controller.text;
        setControllerValue = (it) => controller.text = it;
      }
    }

    final focusCallback = () {
      commitValue();
    };

    subjectFocusNode.addListener(focusCallback);

    final unsubscribe = widget.cell.subscribe(
      interests: ["value", "errors", "loading"],
      onEvent: (event) {
        switch (event.interest) {
          case "value":
            final value = getCellValue(event.payload);
            final controllerValue = getControllerValue();

            if (value != controllerValue) {
              setControllerValue(value);
            }
            break;
          case "errors":
            if (event.payload.isNotEmpty || errors.isNotEmpty) {
              setState(() {
                errors = event.payload;
              });
            }
            break;
          case "loading":
            setState(() {/* Silent */});
            break;
        }
      },
    );

    disposer = () {
      unsubscribe();
      if (controller != null) controller.dispose();
      subjectFocusNode.removeListener(focusCallback);
    };
  }

  commitValue() {
    final value = widget.transout == null ? (getControllerValue()) : widget.transout(getControllerValue());

    if (widget.cell.value != value) {
      widget.cell.value = value;
      widget.cell.validate();
    }

    setState(() {/* Silent */});
  }

  @override
  void dispose() {
    if (disposer != null) disposer();

    if (widget.focusEntry == null) {
      subjectFocusNode.dispose();
    }

    super.dispose();
  }

  bool _isEmpty() => controller == null ? getControllerValue().isEmpty : controller.text.isEmpty;

  hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;
    final entryTheme = theme.entryTheme;

    return entryWrapper(
      context: context,
      margin: widget.margin,
      constraints: widget.constraints,
      theme: theme,
      errors: errors,
      label: widget.label,
      subjectFocusNode: subjectFocusNode,
      enabled: widget.enabled,
      isEmpty: _isEmpty(),
      subjectBuilder: () {
        final textField = !widget.enabled
            ? Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  getControllerValue(),
                  focusNode: subjectFocusNode,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: entryTheme.entryFontFamily,
                    fontSize: entryTheme.entryFontSize,
                    fontWeight: entryTheme.entryFontWeight,
                    color: entryTheme.textEntryColor.disabled,
                  ),
                  onTap: () {
                    FocusScope.of(context).requestFocus(subjectFocusNode);
                  },
                ),
              )
            : TextField(
                style: TextStyle(
                  fontFamily: entryTheme.entryFontFamily,
                  fontSize: entryTheme.entryFontSize,
                  fontWeight: entryTheme.entryFontWeight,
                ),
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                obscureText: localObscureText,
                focusNode: subjectFocusNode,
                textAlignVertical: TextAlignVertical.top,
                textAlign: entryTheme.textAlign,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: !subjectFocusNode.hasFocus && controller.text.isEmpty ? (widget.hintText ?? widget.label) : "",
                  hintStyle: entryTheme.hintStyle,
                ),
                onSubmitted: (value) {
                  if (widget.cell.loading == 0) {
                    if (widget.obscureText || localOnAction == null) {
                      if (widget.textInputAction == TextInputAction.next) {
                        FocusScope.of(context).nextFocus();
                      }
                    } else {
                      FocusScope.of(context).requestFocus(subjectFocusNode);
                      commitValue();
                      localOnAction(DateTime.now().millisecondsSinceEpoch);

                      Future.microtask(() {
                        hideKeyboard();
                      });
                    }
                  } else {
                    FocusScope.of(context).requestFocus(subjectFocusNode);

                    Future.microtask(() {
                      hideKeyboard();
                    });
                  }
                },
                controller: controller,
                cursorColor: entryTheme.textEntryColor.enabled,
                cursorWidth: entryTheme.entryCursorWidth,
                textInputAction: widget.textInputAction,
                keyboardType: widget.keyboardType,
                keyboardAppearance: widget.keyboardAppearance,
              );

        final child = widget.cell.loading > 0
            ? Loading(width: 32.0, height: 32.0)
            : localIcon != null
                ? Material(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    clipBehavior: Clip.antiAlias,
                    color: colorTheme.basis.canvas,
                    child: InkWell(
                      canRequestFocus: false,
                      child: Container(
                        width: 32,
                        height: 32,
                        child: localIcon,
                      ),
                      onLongPress: () {
                        FocusScope.of(context).requestFocus(subjectFocusNode);
                      },
                      onTap: localOnAction == null
                          ? null
                          : () {
                              if (widget.cell.loading == 0) {
                                commitValue();
                                localOnAction(DateTime.now().millisecondsSinceEpoch);

                                if (!widget.obscureText) {
                                  FocusScope.of(context).requestFocus(subjectFocusNode);

                                  Future.microtask(() {
                                    hideKeyboard();
                                  });
                                }
                              }
                            },
                    ),
                  )
                : null;

        return child == null ? textField : Row(children: <Widget>[Expanded(child: textField), child]);
      },
    );
  }
}
