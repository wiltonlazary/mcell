import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'main_drawer.dart';
import 'core/index.dart';
import 'routes.dart';
import 'scenes/home/home.scene.dart';
import 'scenes/login/login.scene.dart';

void main() {
  return runApp(LocalApp());
}

class LocalApp extends StatefulWidget {
  @override
  _LocalAppState createState() => _LocalAppState();
}

class _LocalAppState extends State<LocalApp> {
  final _coreTheme = CoreTheme();
  final _hudLoading = HudLoading();
  Future<dynamic> _initialized;

  @override
  void initState() {
    super.initState();

    _initialized = Future.microtask(() async {
      await Persistence.init();
      await Remote.init();
      await _coreTheme.init();
      await initRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("LocalAppState: build");

    return LoadingFuture(
      future: _initialized,
      builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<HudLoading>.value(value: _hudLoading),
            ChangeNotifierProvider<CoreTheme>.value(value: _coreTheme),
          ],
          child: Builder(
            builder: (context) {
              final theme = Provider.of<CoreTheme>(context);
              final hudLoading = Provider.of<HudLoading>(context);
              final colorTheme = theme.colorTheme;

              return StyledToast(
                textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
                backgroundColor: Color(0x99000000),
                borderRadius: BorderRadius.circular(5.0),
                textPadding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0),
                toastAnimation: StyledToastAnimation.slideFromBottom,
                reverseAnimation: StyledToastAnimation.fade,
                curve: Curves.fastOutSlowIn,
                reverseCurve: Curves.easeOutExpo,
                dismissOtherOnShow: true,
                movingOnWindowChange: true,
                child: ModalProgressHUD(
                  inAsyncCall: hudLoading.active,
                  progressIndicator: Loading(),
                  child: Stage(
                    drawerBuilder: (context) => MainDrawer(),
                    builder: (context, navigatorKey) {
                      return MaterialApp(
                        navigatorKey: navigatorKey,
                        title: 'Laz-flutter',
                        theme: ThemeData(
                          brightness: Brightness.light,
                          fontFamily: theme.fontFamily,
                          canvasColor: colorTheme.basis.canvas,
                          primarySwatch: Colors.blue,
                          accentColor: colorTheme.primary.accent,
                          primaryColor: colorTheme.primary.canvas,
                        ),
                        initialRoute: '/user-registration',
                        debugShowCheckedModeBanner: false,
                        onGenerateRoute:
                            routeFactory(loginCanonicalRoute: LoginScene.canonicalRouting, defaultCanonicalRoute: HomeScene.canonicalRoute),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
