import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../routing.dart';
import '../theme.dart';
import 'loading.dart';
import 'stage.dart';

enum SceneShellActionMode {
  MENU,
  BACK,
}

class SceneShellAction {
  static const menu = SceneShellAction(mode: SceneShellActionMode.MENU);
  static const back = SceneShellAction(mode: SceneShellActionMode.BACK);

  const SceneShellAction({@required this.mode, this.onAction});
  final SceneShellActionMode mode;
  final Function(BuildContext) onAction;
}

class SceneShell extends StatefulWidget {
  SceneShell({
    Key key,
    this.title,
    this.future,
    this.actionBarBuilder,
    this.extraBarBuilder,
    @required this.builder,
    this.action = SceneShellAction.menu,
  }) : super(key: key);

  final String title;
  final Future<dynamic> future;
  final WidgetBuilder builder;
  final WidgetBuilder actionBarBuilder;
  final WidgetBuilder extraBarBuilder;
  final SceneShellAction action;

  @override
  State<StatefulWidget> createState() => SceneShellState();
}

class SceneShellState extends State<SceneShell> {
  static SceneShellState of(BuildContext context) => Provider.of<SceneShellState>(context, listen: false);

  VoidCallback _disposer;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  StageState stageState;
  CoreTheme theme;
  int actionBarPosition = 0;
  final actionBarHeight = 64.0;
  ScrollController scrollController;
  dynamic shared;

  @override
  initState() {
    super.initState();
    stageState = StageState.of(context);
    theme = stageState.theme;
    scrollController = ScrollController();

    _disposer = () {
      scrollController.dispose();
    };
  }

  @override
  void dispose() {
    if (_disposer != null) _disposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = stageState.mediaQuery();
    final theme = stageState.theme;
    final colorTheme = theme.colorTheme;
    EdgeInsets systemPadding = mediaData.padding;
    final safeHeight = mediaData.size.height - systemPadding.bottom - systemPadding.top;
    final topHeight = stageState.appBarHeight + systemPadding.top;
    final keyboardVisible = mediaData.viewInsets.bottom != 0.0;
    final barsTotalHeight = stageState.appBarHeight + actionBarHeight;
    final contentMinHeight = mediaData.size.height - barsTotalHeight - (theme.spacing * 2) - systemPadding.bottom - 4;
    final contentMaxWidth = 980.0;
    final availableWidth = stageState.openedDrawer ? mediaData.size.width - stageState.drawerWidth : mediaData.size.width;
    print("keyboardVisible=$keyboardVisible, size=${mediaData.size} contentMinHeight=$contentMinHeight");

    if (widget.actionBarBuilder != null) {
      if (mediaData.size.width > 980) {
        actionBarPosition = 1;
      } else if (keyboardVisible || mediaData.size.height < 500) {
        actionBarPosition = 3;
      } else {
        actionBarPosition = 2;
      }
    }

    Widget localView() {
      //OBS: must be created before actionBarWidget
      final contentWidget = widget.builder(context);

      actionBarWidget(double paddingBottom) => Container(
            height: 64.0,
            padding: EdgeInsets.fromLTRB(theme.spacing * 2, theme.spacing, theme.spacing * 2, theme.spacing),
            decoration: BoxDecoration(
              color: colorTheme.basis.canvas,
              boxShadow: actionBarPosition == 1
                  ? [BoxShadow(color: Colors.black26, spreadRadius: -5, blurRadius: 5, offset: Offset(0.0, 5.0))]
                  : [BoxShadow(color: Colors.black26, spreadRadius: -5, blurRadius: 5, offset: Offset(0.0, -5.0))],
            ),
            child: Builder(
              builder: (context) => widget.actionBarBuilder(context),
            ),
          );

      return Stack(
        children: <Widget>[
          Positioned(
            left: 0.0,
            top: actionBarPosition == 1 ? actionBarHeight : 0.0,
            width: availableWidth,
            height: actionBarPosition == 1 || actionBarPosition == 2 ? safeHeight - barsTotalHeight : safeHeight - stageState.appBarHeight,
            child: Scrollbar(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                controller: scrollController,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Container(
                          color: colorTheme.basis.canvas,
                          constraints: BoxConstraints(minHeight: contentMinHeight, maxWidth: contentMaxWidth),
                          child: contentWidget,
                        ),
                      ),
                      if (actionBarPosition > 0)
                        Offstage(
                          offstage: actionBarPosition != 3,
                          child: actionBarWidget(systemPadding.bottom),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (actionBarPosition == 1 || actionBarPosition == 2)
            Positioned(
              left: 0,
              top: actionBarPosition == 1 ? 0.0 : safeHeight - barsTotalHeight,
              width: availableWidth,
              height: actionBarHeight,
              child: actionBarWidget(actionBarPosition == 1 ? 0.0 : systemPadding.bottom),
            )
        ],
      );
    }

    return Provider.value(
      value: this,
      child: Scaffold(
        key: scaffoldKey,
        drawer: stageState.openedDrawer ? null : Drawer(child: stageState.drawerBuilder(context)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: topHeight,
              padding: EdgeInsets.only(top: systemPadding.top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0, 0.9],
                  colors: [
                    Color(0xff049AE8),
                    Color(0xff170085),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: stageState.appBarHeight,
                    height: stageState.appBarHeight,
                    margin: EdgeInsets.only(left: 2.0),
                    child: stageState.openedDrawer && widget.action.mode == SceneShellActionMode.MENU
                        ? null
                        : Material(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.transparent,
                            child: InkWell(
                              child: Icon(
                                widget.action.mode == SceneShellActionMode.BACK ? Icons.arrow_back : Icons.menu,
                                color: Colors.white,
                              ),
                              onLongPress: () {
                                scaffoldKey.currentState.openDrawer();
                              },
                              onTap: () {
                                if (widget.action.mode == SceneShellActionMode.MENU) {
                                  scaffoldKey.currentState.openDrawer();
                                } else if (widget.action.onAction != null) {
                                  widget.action.onAction(context);
                                } else {
                                  Router.of(context).pop();
                                }
                              },
                            ),
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 12.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 12),
                          child: Center(
                            child: Container(
                              height: 32,
                              width: 32,
                              child: Material(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                clipBehavior: Clip.antiAlias,
                                color: Colors.white,
                                child: InkWell(
                                  child: Icon(Icons.perm_identity),
                                  onTap: () {
                                    Router.of(context).pushNamed("/home");
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.future != null
                  ? Container(
                      color: colorTheme.basis.canvas,
                      constraints: BoxConstraints(minHeight: contentMinHeight),
                      child: LoadingFuture(future: widget.future, builder: (context) => localView()),
                    )
                  : localView(),
            ),
          ],
        ),
      ),
    );
  }
}
