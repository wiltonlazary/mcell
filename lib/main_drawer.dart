import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'core/index.dart';
import 'services/login_service.dart';

class MainDrawer extends StatefulWidget {
  MainDrawer({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  VoidCallback _disposer;
  StageState stageState;
  CoreTheme theme;

  @override
  initState() {
    super.initState();
    stageState = StageState.of(context);
    theme = stageState.theme;
    _disposer = () {};
  }

  @override
  void dispose() {
    if (_disposer != null) _disposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaData = stageState.mediaQuery();
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;
    EdgeInsets systemPadding = mediaData.padding;
    final topHeight = stageState.appBarHeight + systemPadding.top;

    Widget item({bool aways = false, String canonical, String label, IconData icon, onAction()}) {
      return Container(
        child: Material(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (aways ||
                  (NavigatorRouter.current(stageState.navigatorKey.currentState).settings.arguments as RouteArguments).canonical !=
                      canonical) {
                onAction();
              } else if (!stageState.openedDrawer) {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: colorTheme.primary.canvas,
                  ),
                  SizedBox(width: 18),
                  Text(
                    label,
                    style: TextStyle(
                      color: colorTheme.basis.canvasFace,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorTheme.basis.canvas,
        border: Border(right: BorderSide(color: colorTheme.basis.weaker, width: 1.0)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: topHeight,
            padding: EdgeInsets.only(top: systemPadding.top),
            decoration: BoxDecoration(
              color: Color(0xff049AE8),
            ),
            child: Center(
              child: Text(
                'Loja fantástica',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          item(
            aways: true,
            icon: Icons.polymer,
            label: "Tema",
            onAction: () {
              theme.update((it) async {
                it.type = it.type == CoreThemeType.HIT ? CoreThemeType.MATERIAL : CoreThemeType.HIT;
                await it.init();

                if (!stageState.openedDrawer) {
                  Navigator.pop(context);
                }
              });
            },
          ),
          // item(
          //   icon: Icons.home,
          //   title: "Home",
          //   onAction: () {
          //   NatigatorRouter.pushReplacementNamed(navigatorKey.currentState, "/");
          //   },
          // ),
          item(
            icon: Icons.group,
            canonical: "user-registration",
            label: "Usuários",
            onAction: () {
              NavigatorRouter.pushNamedAndRemoveUntilRoot(stageState.navigatorKey.currentState, "/user-registration");
            },
          ),
          item(
            icon: Icons.exit_to_app,
            label: "Logout",
            onAction: () {
              HudLoading.of(context).active = true;

              LoginService.logout().then((_) {
                stageState.update();
                NavigatorRouter.pushNamedAndRemoveUntilRoot(stageState.navigatorKey.currentState, "/login");
                HudLoading.of(context).active = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
