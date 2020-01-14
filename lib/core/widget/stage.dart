import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../mcell.dart';
import '../remote.dart';
import '../theme.dart';

typedef StageWidgetBuilder = Widget Function(BuildContext context, GlobalKey<NavigatorState> navigatorKey);

class Stage extends StatefulWidget {
  Stage({
    Key key,
    @required this.builder,
    @required this.drawerBuilder,
  }) : super(key: key);

  final StageWidgetBuilder builder;
  final WidgetBuilder drawerBuilder;

  @override
  State<StatefulWidget> createState() => StageState();
}

class StageState extends State<Stage> {
  static StageState of(BuildContext context) => Provider.of<StageState>(context, listen: false);

  VoidCallback _disposer;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  ModelCell cell;
  int loadingCount = 0;
  CoreTheme theme;
  var appBarHeight = 48.0;
  var drawerWidth = 250.0;
  var openDrawerWhenWidth = 980;
  var openedDrawer = false;

  WidgetBuilder get drawerBuilder => widget.drawerBuilder;

  update() {
    setState(() {
      _calcOpenedDrawer();
    });
  }

  _calcOpenedDrawer() {
    final mediaData = mediaQuery();
    openedDrawer = Remote.token != null && mediaData.size.width > (drawerWidth + openDrawerWhenWidth);
  }

  incLoading(int timestamp) {
    loadingCount += 1;

    if (cell.loading == 0) {
      cell.loading = timestamp;
    }
  }

  decLoading(int timestamp) {
    if (loadingCount > 0) {
      loadingCount -= 1;

      if (loadingCount == 0) {
        cell.loading = 0;
      }
    }
  }

  @override
  initState() {
    super.initState();
    cell = ModelCell(parent: this);
    theme = CoreTheme.of(context);
    _calcOpenedDrawer();
    final onMetricsChanged = WidgetsBinding.instance.window.onMetricsChanged;

    WidgetsBinding.instance.window.onMetricsChanged = () {
      onMetricsChanged();
      update();
    };

    _disposer = () {
      WidgetsBinding.instance.window.onMetricsChanged = onMetricsChanged;
      cell.dispose();
    };
  }

  @override
  void dispose() {
    if (_disposer != null) _disposer();
    super.dispose();
  }

  MediaQueryData mediaQuery() => MediaQueryData.fromWindow(WidgetsBinding.instance.window);

  @override
  Widget build(BuildContext context) {
    final mediaData = mediaQuery();

    return Provider.value(
      value: this,
      child: openedDrawer
          ? Stack(
              children: <Widget>[
                Positioned(
                  top: 0.0,
                  left: drawerWidth,
                  width: mediaData.size.width - drawerWidth,
                  height: mediaData.size.height,
                  child: widget.builder(context, navigatorKey),
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  width: drawerWidth,
                  height: mediaData.size.height,
                  child: widget.drawerBuilder(context),
                ),
              ],
            )
          : widget.builder(context, navigatorKey),
    );
  }
}
