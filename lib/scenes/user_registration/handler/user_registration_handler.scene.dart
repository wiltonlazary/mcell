import 'package:flutter/material.dart';
import '../../../core/index.dart';
import 'user_registration_handler.model.dart';

class UserRegistrationHandlerScene extends StatefulWidget {
  static final routes = {
    "/user-registration/:tid/:action": canonicalRoute,
  };

  static final canonicalRoute = CanonicalRoute(
    "user-registration-handler",
    (context, settings, params) {
      final isNewRegister = params["tid"] == "_";

      return SceneShell(
        title: params["tid"] == "_" ? "Novo usuário" : "Usuário",
        action: (settings.arguments as RouteArguments).arguments == null
            ? SceneShellAction(
                mode: SceneShellActionMode.BACK,
                onAction: (context) {
                  Router.of(context).pushNamedAndRemoveUntilRoot("/user-registration");
                },
              )
            : SceneShellAction(
                mode: SceneShellActionMode.BACK,
                onAction: (context) {
                  (settings.arguments as RouteArguments).arguments["onBack"](context);
                },
              ),
        actionBarBuilder: (context) {
          final sceneShellState = SceneShellState.of(context);
          final stageState = sceneShellState.stageState;
          final theme = stageState.theme;
          final model = sceneShellState.shared.model;
          final stageWidth = sceneShellState.stageState.mediaQuery().size.width;

          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (!isNewRegister)
                Container(
                  width: 180.0,
                  child: ButtonCell(
                    label: "Remover Usuário",
                    cell: model.loading,
                    onAction: model.delete,
                    precedence: ButtonPrecedence.secondary,
                  ),
                ),
              if (!isNewRegister && stageWidth > stageState.openDrawerWhenWidth) SizedBox(width: theme.spacing) else Spacer(),
              Container(
                width: 180.0,
                child: ButtonCell(
                  label: "Salvar Usuário",
                  cell: model.loading,
                  onAction: model.save,
                ),
              ),
            ],
          );
        },
        builder: (context) => UserRegistrationHandlerScene(settings: settings, params: params),
      );
    },
  );

  UserRegistrationHandlerScene({Key key, this.settings, this.params}) : super(key: key);

  final Map<String, dynamic> params;
  final RouteSettings settings;

  @override
  _UserRegistrationHandlerSceneState createState() => _UserRegistrationHandlerSceneState();
}

class _UserRegistrationHandlerSceneState extends SceneState<UserRegistrationHandlerScene, UserRegistrationHandlerModel> {
  @override
  createModel() {
    final routeArguments = (widget.settings.arguments as RouteArguments);

    return UserRegistrationHandlerModel(
      onSaved: routeArguments.arguments == null ? null : routeArguments.arguments["onSaved"],
      onDeleted: routeArguments.arguments == null ? null : routeArguments.arguments["onDeleted"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingFuture(
      future: model.initialized,
      builder: (context) => ModelCellWatcher(
        cell: model.store,
        interests: ["value"],
        builder: (context, store, _) {
          final theme = CoreTheme.of(context);
          final enabled = !model.hasTid();

          return Padding(
            padding: theme.margin,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextEntryCell(
                  cell: model["email"],
                  label: "Email",
                  margin: theme.margin,
                  keyboardType: TextInputType.emailAddress,
                  enabled: enabled,
                ),
                TextEntryCell(
                  cell: model["name"],
                  label: "Nome",
                  margin: theme.margin,
                  enabled: enabled,
                ),
                ComboCell(
                  label: "Nível",
                  cell: model["accountUserRole"],
                  margin: theme.margin,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
