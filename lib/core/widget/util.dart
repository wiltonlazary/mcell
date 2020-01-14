import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

typedef OnAction(int timestamp);

class ReferencedCallback {
  ReferencedCallback({
    this.reference,
    @required this.callback,
  });

  final dynamic reference;

  final void Function(BuildContext context, dynamic reference, dynamic data) callback;
}

Tuple2<FocusEntry, ValueChanged<RawKeyEvent>> onFocusEntryKeyBuilder(BuildContext context, FocusEntry focusEntry,
        {ValueChanged<RawKeyEvent> onKey}) =>
    Tuple2(focusEntry, (RawKeyEvent event) {
      if (event.logicalKey == LogicalKeyboardKey.tab && event is RawKeyUpEvent) {
        if (event.isShiftPressed && focusEntry.prev != null) {
          print("focusNodePrevious");
          FocusScope.of(context).requestFocus(focusEntry.prev.node);
        } else if (focusEntry.next != null) {
          print("focusNodeNext");
          FocusScope.of(context).requestFocus(focusEntry.next.node);
        }
      } else if (onKey != null) {
        onKey(event);
      }
    });

class FocusEntry {
  final FocusNode node;
  FocusEntry prev;
  FocusEntry next;
  FocusEntry({this.node, this.prev, this.next});

  void dispose() {
    node.dispose();
  }
}

class FocusEntryKey extends RawKeyboardListener {
  FocusEntryKey({
    Key key,
    Tuple2<FocusEntry, ValueChanged<RawKeyEvent>> onFocusKey,
    @required Widget child,
  }) : super(key: key, focusNode: onFocusKey.item1.node, onKey: onFocusKey.item2, child: child);
}

Tuple2<FocusNode, ValueChanged<RawKeyEvent>> onFocusNodeKeyBuilder(BuildContext context, FocusNode focusNode,
        {ValueChanged<RawKeyEvent> onKey}) =>
    Tuple2(focusNode, (RawKeyEvent event) {
      if (event.logicalKey == LogicalKeyboardKey.tab && event is RawKeyUpEvent) {
        if (event.isShiftPressed) {
          print("focusNodePrevious");
          FocusScope.of(context).previousFocus();
        } else {
          print("focusNodeNext");
          FocusScope.of(context).nextFocus();
        }
      } else if (onKey != null) {
        onKey(event);
      }
    });

class FocusNodeKey extends RawKeyboardListener {
  FocusNodeKey({
    Key key,
    Tuple2<FocusNode, ValueChanged<RawKeyEvent>> onFocusKey,
    @required Widget child,
  }) : super(key: key, focusNode: onFocusKey.item1, onKey: onFocusKey.item2, child: child);
}

class RichBoxShadow extends BoxShadow {
  final BlurStyle blurStyle;

  const RichBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.blurStyle = BlurStyle.normal,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(this.blurStyle, blurSigma);
    assert(() {
      if (debugDisableShadows) result.maskFilter = null;
      return true;
    }());
    return result;
  }
}
