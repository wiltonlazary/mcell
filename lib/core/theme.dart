import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum CoreThemeType {
  HIT,
  MATERIAL,
}

class HudLoading with ChangeNotifier {
  static HudLoading of(BuildContext context) => Provider.of<HudLoading>(context, listen: false);
  bool _active = false;

  get active => _active;

  set active(value) {
    _active = value;
    notifyListeners();
  }
}

class LoadingTheme {
  static LoadingTheme instance = LoadingTheme();

  double stroke = 3.0;
  Color color = Colors.blueAccent;
  Color backgroundColor = Color.fromARGB(255, 180, 180, 180);
}

class CoreTheme with ChangeNotifier {
  CoreThemeType type = CoreThemeType.HIT;
  String fontFamily;
  double spacing;
  EdgeInsets padding;
  EdgeInsets margin;
  double radius;
  double stroke;
  ColorTheme colorTheme;
  ChipTheme chipTheme;
  EntryTheme entryTheme;
  CardContainerTheme cardContainerTheme;
  ButtonTheme buttonTheme;
  SwitchTheme switchTheme;
  LoadingTheme loadingTheme = LoadingTheme();

  static CoreTheme of(BuildContext context) => Provider.of<CoreTheme>(context, listen: false);

  Future<void> init() async {
    fontFamily = "Ubuntu";
    stroke = 3.0;
    spacing = 10.0;
    padding = EdgeInsets.all(spacing);
    margin = EdgeInsets.all(spacing);
    colorTheme = ColorTheme()..init(this);
    chipTheme = ChipTheme()..init(this);
    entryTheme = EntryTheme()..init(this);
    cardContainerTheme = CardContainerTheme()..init(this);
    buttonTheme = ButtonTheme()..init(this);
    switchTheme = SwitchTheme()..init(this);
  }

  Future<void> update(Future<void> body(CoreTheme it)) async {
    await body(this);
    notifyListeners();
  }
}

class CoreColor {
  CoreColor({
    @required this.canvas,
    @required this.canvasFace,
    @required this.normal,
    @required this.normalFace,
    @required this.weak,
    @required this.weakFace,
    @required this.weaker,
    @required this.weakerFace,
    @required this.strong,
    @required this.strongFace,
    @required this.stronger,
    @required this.strongerFace,
    @required this.accent,
    @required this.accentFace,
  });

  final Color canvas;
  final Color canvasFace;
  final Color normal;
  final Color normalFace;
  final Color accent;
  final Color accentFace;
  final Color weak;
  final Color weakFace;
  final Color weaker;
  final Color weakerFace;
  final Color strong;
  final Color strongFace;
  final Color stronger;
  final Color strongerFace;
}

class ColorTheme {
  CoreColor basis;
  CoreColor primary;
  CoreColor secondary;
  CoreColor error;

  Future<void> init(CoreTheme coreTheme) async {
    basis = CoreColor(
      canvas: Color.fromARGB(255, 250, 250, 250),
      canvasFace: Color.fromARGB(255, 33, 33, 33),
      accent: Color.fromARGB(255, 33, 33, 33),
      accentFace: Colors.white,
      normal: Color.fromARGB(255, 140, 140, 140),
      normalFace: Colors.white,
      weak: Color.fromARGB(255, 180, 180, 180),
      weakFace: Colors.white,
      weaker: Color.fromARGB(255, 210, 210, 210),
      weakerFace: Colors.white,
      strong: Color.fromARGB(255, 33, 33, 33),
      strongFace: Colors.white,
      stronger: Color.fromARGB(255, 10, 10, 10),
      strongerFace: Colors.white,
    );

    primary = CoreColor(
      canvas: Color.fromARGB(255, 12, 94, 194),
      canvasFace: Colors.white,
      accent: Color.fromARGB(255, 2, 64, 164),
      accentFace: Colors.white,
      normal: Colors.blue[200],
      normalFace: Colors.white,
      weak: Colors.transparent,
      weakFace: Colors.transparent,
      weaker: Colors.transparent,
      weakerFace: Colors.transparent,
      strong: Colors.transparent,
      strongFace: Colors.transparent,
      stronger: Color.fromARGB(255, 23, 0, 133),
      strongerFace: Colors.white,
    );

    secondary = CoreColor(
      canvas: Colors.white,
      canvasFace: Color.fromARGB(255, 12, 94, 194),
      accent: Color.fromARGB(255, 220, 220, 220),
      accentFace: Color.fromARGB(255, 12, 94, 194),
      normal: Colors.transparent,
      normalFace: Colors.transparent,
      weak: Colors.transparent,
      weakFace: Colors.transparent,
      weaker: Colors.transparent,
      weakerFace: Colors.transparent,
      strong: Colors.transparent,
      strongFace: Colors.transparent,
      stronger: Colors.transparent,
      strongerFace: Colors.transparent,
    );

    error = CoreColor(
      canvas: Colors.red,
      canvasFace: Colors.white,
      normal: Colors.red,
      normalFace: Colors.white,
      weak: Colors.red,
      weakFace: Colors.white,
      weaker: Colors.red,
      weakerFace: Colors.white,
      strong: Colors.red,
      strongFace: Colors.white,
      stronger: Colors.red,
      strongerFace: Colors.white,
      accent: Colors.red,
      accentFace: Colors.white,
    );

    coreTheme.loadingTheme.color = Colors.blueAccent;
    coreTheme.loadingTheme.backgroundColor = basis.weak;
  }
}

class EntryColor {
  EntryColor({
    @required this.disabled,
    @required this.disabledError,
    @required this.enabled,
    @required this.enabledError,
    @required this.focused,
    @required this.focusedError,
  });

  final Color disabled;
  final Color disabledError;
  final Color enabled;
  final Color enabledError;
  final Color focused;
  final Color focusedError;
}

class EntryTheme {
  BoxDecoration disabledBorder;
  BoxDecoration disabledBorderError;
  BoxDecoration enabledBorder;
  BoxDecoration enabledBorderError;
  BoxDecoration focusedBorder;
  BoxDecoration focusedBorderError;

  double entryTop;
  TextAlign textAlign;
  double height;
  TextStyle hintStyle;
  EntryColor textEntryColor;

  EdgeInsetsGeometry entryPadding;
  String entryFontFamily;
  FontWeight entryFontWeight;
  double entryFontSize;
  double entryCursorWidth;
  double entryHeight;
  double borderTop;
  double borderXAdjust;

  EdgeInsetsGeometry labelPadding;
  double lebelHeight;
  double labelLeft;
  double labelTop;
  String labelFontFamily;
  FontWeight labelFontWeight;
  double labelFontSize;
  EntryColor labelEntryColor;

  EdgeInsetsGeometry errorPadding;
  double errorHeight;
  double errorLeft;
  double errorTop;
  String errorFontFamily;
  FontWeight errorFontWeight;
  double errorFontSize;
  EntryColor errorEntryColor;

  double iconSize;

  Future<void> init(CoreTheme coreTheme) async {
    final colorTheme = coreTheme.colorTheme;
    hintStyle = TextStyle(fontSize: 16, color: colorTheme.basis.weak);
    iconSize = 32;
    final colorThemeBasis = colorTheme.basis;
    final colorThemeError = colorTheme.error;

    textEntryColor = EntryColor(
      disabled: colorThemeBasis.canvasFace,
      disabledError: colorThemeBasis.canvasFace,
      enabled: colorThemeBasis.canvasFace,
      enabledError: colorThemeBasis.canvasFace,
      focused: colorThemeBasis.canvasFace,
      focusedError: colorThemeBasis.canvasFace,
    );

    labelEntryColor = EntryColor(
      disabled: colorThemeBasis.weaker,
      disabledError: colorThemeError.weaker,
      enabled: colorThemeBasis.normal,
      enabledError: colorThemeError.normal,
      focused: colorThemeBasis.strong,
      focusedError: colorThemeError.strong,
    );

    errorEntryColor = EntryColor(
      disabled: colorThemeBasis.normal,
      disabledError: colorThemeError.normal,
      enabled: colorThemeBasis.strong,
      enabledError: colorThemeError.strong,
      focused: colorThemeBasis.strong,
      focusedError: colorThemeError.strong,
    );

    if (coreTheme.type == CoreThemeType.HIT) {
      final radius = BorderRadius.circular(4.0);

      disabledBorder = BoxDecoration(
        border: Border.all(color: colorThemeBasis.weaker, width: 1.0),
        borderRadius: radius,
        //boxShadow: [BoxShadow(color: colorTheme.disabledBorder, blurRadius: 1)],
      );

      disabledBorderError = BoxDecoration(
        border: Border.all(color: colorThemeError.weaker, width: 1.0),
        borderRadius: radius,
        //boxShadow: [BoxShadow(color: colorTheme.disabledBorderError, blurRadius: 1)],
      );

      enabledBorder = BoxDecoration(
        border: Border.all(color: colorThemeBasis.normal, width: 1.0),
        borderRadius: radius,
        //boxShadow: [BoxShadow(color: colorTheme.enabledBorder, blurRadius: 1)],
      );

      enabledBorderError = BoxDecoration(
        border: Border.all(color: colorThemeError.normal, width: 1.0),
        borderRadius: radius,
        //boxShadow: [BoxShadow(color: colorTheme.enabledBorderError, blurRadius: 1)],
      );

      focusedBorder = BoxDecoration(
        border: Border.all(color: colorThemeBasis.strong, width: 1.0),
        borderRadius: radius,
        color: colorTheme.basis.canvas,
        boxShadow: [BoxShadow(color: colorThemeBasis.strong, blurRadius: 1.0)],
      );

      focusedBorderError = BoxDecoration(
        border: Border.all(color: colorThemeError.strong, width: 1.0),
        borderRadius: radius,
        color: colorTheme.basis.canvas,
        boxShadow: [BoxShadow(color: colorThemeError.strong, blurRadius: 1.0)],
      );

      height = 60;
      entryTop = 6;
      textAlign = TextAlign.start;
      entryPadding = EdgeInsets.fromLTRB(8, 0, 8, 0);
      entryFontFamily = coreTheme.fontFamily;
      entryFontWeight = FontWeight.w400;
      entryFontSize = 16;
      entryCursorWidth = 1;
      entryHeight = 40;
      borderTop = 7;
      borderXAdjust = 1.5;

      labelPadding = EdgeInsets.fromLTRB(4, 0, 4, 0);
      lebelHeight = 16;
      labelLeft = 12;
      labelTop = 0;
      labelFontFamily = coreTheme.fontFamily;
      labelFontWeight = FontWeight.w500;
      labelFontSize = 12;

      errorPadding = EdgeInsets.fromLTRB(4, 0, 4, 0);
      errorHeight = 12;
      errorLeft = 8;
      errorTop = 50;
      errorFontFamily = coreTheme.fontFamily;
      errorFontWeight = FontWeight.w500;
      errorFontSize = 9;
    } else {
      disabledBorder = BoxDecoration(
        border: Border(bottom: BorderSide(color: colorThemeBasis.weaker, width: 1.0)),
      );

      disabledBorderError = BoxDecoration(
        border: Border(bottom: BorderSide(color: colorThemeError.weaker, width: 1.0)),
      );

      enabledBorder = BoxDecoration(
        border: Border(bottom: BorderSide(color: colorThemeBasis.normal, width: 1.0)),
      );

      enabledBorderError = BoxDecoration(
        border: Border(bottom: BorderSide(color: colorThemeError.normal, width: 1.0)),
      );

      focusedBorder = BoxDecoration(
        border: Border(bottom: BorderSide(color: colorThemeBasis.strong, width: 1.5)),
      );

      focusedBorderError = BoxDecoration(
        border: Border(bottom: BorderSide(color: colorThemeError.strong, width: 1.5)),
      );

      height = 60;
      entryTop = 8;
      textAlign = TextAlign.start;
      entryPadding = EdgeInsets.fromLTRB(0, 0, 0, 0);
      entryFontFamily = coreTheme.fontFamily;
      entryFontWeight = FontWeight.w400;
      entryFontSize = 16;
      entryCursorWidth = 1;
      entryHeight = 40;
      borderTop = 6;
      borderXAdjust = 0;

      labelPadding = EdgeInsets.fromLTRB(0, 0, 0, 0);
      lebelHeight = 16;
      labelLeft = 0;
      labelTop = 0;
      labelFontFamily = coreTheme.fontFamily;
      labelFontWeight = FontWeight.w500;
      labelFontSize = 12;

      errorPadding = EdgeInsets.fromLTRB(0, 0, 0, 0);
      errorHeight = 12;
      errorLeft = 0;
      errorTop = 50;
      errorFontFamily = coreTheme.fontFamily;
      errorFontWeight = FontWeight.w500;
      errorFontSize = 9;
    }
  }
}

class CardContainerTheme {
  ShapeBorder shape;
  double elevation;

  Future<void> init(CoreTheme coreTheme) async {
    if (coreTheme.type == CoreThemeType.HIT) {
      shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0));
      elevation = 2;
    } else {
      shape = null;
      elevation = 1;
    }
  }
}

class ChipTheme {
  BoxDecoration border;
  Color closeColor;

  Future<void> init(CoreTheme coreTheme) async {
    final colorTheme = coreTheme.colorTheme;
    final coreColor = colorTheme.basis;
    final coreColorError = colorTheme.error;
    closeColor = coreColor.strong;

    if (coreTheme.type == CoreThemeType.HIT) {
      border = BoxDecoration(
        border: Border.all(color: coreColor.normal, width: 1.0),
        borderRadius: BorderRadius.circular(4.0),
        //boxShadow: [BoxShadow(color: colorTheme.enabledBorder, blurRadius: 1)],
      );
    } else {
      border = BoxDecoration(
        border: Border.all(color: coreColor.normal, width: 1.0),
        borderRadius: BorderRadius.circular(4.0),
        //boxShadow: [BoxShadow(color: colorTheme.enabledBorder, blurRadius: 1)],
      );
    }
  }
}

class ButtonTheme {
  ShapeBorder primaryShape;

  ShapeBorder secondaryShape;
  double height;

  Future<void> init(CoreTheme coreTheme) async {
    final colorTheme = coreTheme.colorTheme;
    final coreColorBasis = colorTheme.basis;
    final coreColorPrimary = colorTheme.primary;
    final coreColorSecondary = colorTheme.secondary;

    if (coreTheme.type == CoreThemeType.HIT) {
      final radius = BorderRadius.circular(25.0);
      primaryShape = RoundedRectangleBorder(side: BorderSide(color: coreColorPrimary.canvas, width: 2.0), borderRadius: radius);
      secondaryShape = RoundedRectangleBorder(side: BorderSide(color: coreColorPrimary.canvas, width: 2.0), borderRadius: radius);
      height = 40;
    } else {
      final radius = BorderRadius.circular(10.0);
      primaryShape = RoundedRectangleBorder(side: BorderSide(color: coreColorPrimary.canvas, width: 2.0), borderRadius: radius);
      secondaryShape = RoundedRectangleBorder(side: BorderSide(color: coreColorPrimary.canvas, width: 2.0), borderRadius: radius);
      height = 40;
    }
  }
}

class SwitchTheme {
  double marginCompensation;
  Color activeColor;
  Color activeTrackColor;
  Color inactiveThumbColor;
  Color inactiveTrackColor;

  Future<void> init(CoreTheme coreTheme) async {
    final colorTheme = coreTheme.colorTheme;
    final colorThemeBasis = colorTheme.basis;
    final colorThemePrimary = colorTheme.primary;

    activeColor = colorThemePrimary.canvas;
    activeTrackColor = colorThemePrimary.normal;
    inactiveThumbColor = colorThemeBasis.canvas;
    inactiveTrackColor = colorThemeBasis.weaker;

    if (coreTheme.type == CoreThemeType.HIT) {
      marginCompensation = -10;
    } else {
      marginCompensation = -10;
    }
  }
}
