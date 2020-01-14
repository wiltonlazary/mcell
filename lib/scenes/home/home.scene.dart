import 'package:flutter/material.dart';

import '../../core/index.dart';
import '../../services/user_service.dart';
import 'home.model.dart';

class HomeScene extends StatefulWidget {
  static const title = "Home";

  static final routes = {
    "/": canonicalRoute,
    "/home": canonicalRoute,
  };

  static final canonicalRoute = CanonicalRoute(
    "home",
    (context, settings, params) => SceneShell(
      title: HomeScene.title,
      builder: (context) => HomeScene(params: params),
    ),
  );

  HomeScene({Key key, this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  _HomeSceneState createState() => _HomeSceneState();
}

class _HomeSceneState extends SceneState<HomeScene, HomeModel> {
  @override
  createModel() => HomeModel();

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;

    return Column(
      children: <Widget>[
        Center(
          child: Container(
            width: 320,
            height: 330,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      width: 170,
                      height: 34,
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Image.asset("resources/images/ame-logo.png")),
                  TextEntryCell(cell: model["text"], label: "Digite seu email", margin: EdgeInsets.fromLTRB(20, 20, 20, 0)),
                  TextEntryCell(cell: model["text"], label: "Digite sua senha", margin: EdgeInsets.fromLTRB(20, 20, 20, 0)),
                  Container(
                    margin: EdgeInsets.fromLTRB(22, 0, 20, 10),
                    padding: EdgeInsets.only(right: 120.0),
                    child: Link(
                      label: 'Esqueci minha senha',
                      onAction: () {
                        //TODO
                      },
                    ),
                  ),
                  ButtonCell(
                    label: "Entrar",
                    cell: model.loading,
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    onAction: (timestamp) {
                      Router.of(context).pushNamed("/user/1234/show");
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
