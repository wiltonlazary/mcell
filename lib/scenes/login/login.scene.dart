import 'package:flutter/material.dart';

import '../../core/index.dart';
import 'login.model.dart';

@immutable
class LoginScene extends StatefulWidget {
  static final routes = {"/login": canonicalRouting};

  static CanonicalRoute canonicalRouting = CanonicalRoute(
    "login",
    (context, settings, params) => LoginScene(params: params),
  );

  LoginScene({Key key, this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  _LoginSceneState createState() => _LoginSceneState();
}

class _LoginSceneState extends ViewState<LoginScene, LoginModel> {
  @override
  createModel() => LoginModel();

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;

    return builder((context) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.9],
            colors: [
              Color.fromARGB(255, 0, 189, 255),
              Color.fromARGB(255, 23, 0, 133),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 320,
            height: 330,
            child: Card(
              color: colorTheme.basis.canvas,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    width: 170,
                    height: 34,
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Image.asset("resources/images/ame-logo.png"),
                  ),
                  TextEntryCell(
                    cell: model["email"],
                    label: "Digite seu email",
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  ),
                  TextEntryCell(
                    cell: model["password"],
                    label: "Digite sua senha",
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    obscureText: true,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(right: 120.0),
                    child: Link(
                      margin: EdgeInsets.fromLTRB(22, 0, 20, 10),
                      label: 'Esqueci minha senha',
                      onAction: () {
                        print("xxx");
                      },
                    ),
                  ),
                  ButtonCell(
                    label: "Entrar",
                    cell: model.loading,
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    onAction: (timestamp) {
                      model.submit(timestamp);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
