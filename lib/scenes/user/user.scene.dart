import 'package:flutter/material.dart';

import '../../core/index.dart';
import 'user.model.dart';

class UsersScene extends StatefulWidget {
  static const title = "Usuários";
  static final routes = {"/user/:tid/:action": canonicalRoute};

  static final canonicalRoute = CanonicalRoute(
    "users",
    (context, settings, params) => SceneShell(
      title: UsersScene.title,
      action: SceneShellAction.back,
      builder: (context) => UsersScene(params: params),
    ),
  );

  UsersScene({Key key, this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  _UsersSceneState createState() => _UsersSceneState();
}

class _UsersSceneState extends SceneState<UsersScene, UserModel> {
  @override
  createModel() => UserModel();

  @override
  void initState() {
    super.initState();

    print("params: ${widget.params}");

    addDisposeListener((model["enabled"]).subscribe(
      onEvent: (event) {
        print("event: ${event.payload}");
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final margin = EdgeInsets.only(left: theme.spacing, top: theme.spacing, right: theme.spacing);

    return Wrap(
      // spacing: theme.spacing,
      // runSpacing: theme.spacing,
      children: <Widget>[
        TextEntryCell(
          cell: model["email"],
          label: "Digite seu email",
          margin: margin,
        ),
        TextEntryCell(
          cell: model["email"],
          label: "Digite sua senha",
          margin: margin,
          keyboardType: TextInputType.emailAddress,
          keyboardAppearance: Brightness.dark,
        ),
        ButtonCell(
          label: "Entrar",
          cell: model.loading,
          margin: margin,
          onAction: (timestamp) {
            //model.submit(timestamp);
            Router.of(context).pop();
          },
        ),
        SizedBox(height: 20.0),
        ButtonCell(
          precedence: ButtonPrecedence.secondary,
          label: "Entrar",
          cell: model.loading,
          margin: margin,
          onAction: (timestamp) {
            //model.submit(timestamp);
            //Router.of(context).pop();
          },
        ),
        SwitchCell(
          cell: model["enabled"],
          margin: margin,
        ),
        CheckboxCell(
          cell: model["enabled"],
          margin: margin,
        ),
        ComboCell(
          label: "Options",
          cell: model["options"],
          margin: margin,
        ),
        TextEntryCell(
          cell: model["fetchQuery"],
          label: "Digite sua busca",
          margin: margin,
          textInputAction: TextInputAction.search,
          icon: Icon(
            Icons.search,
            //color: theme.colorTheme.active,
          ),
          onAction: (timestamp) {
            model.list(timestamp);
          },
        ),
      ],
    );
  }
}
