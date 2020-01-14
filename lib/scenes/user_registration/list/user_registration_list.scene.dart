import 'package:flutter/material.dart';
import '../../../core/index.dart';
import '../user.dart';
import '../handler/user_registration_handler.model.dart';
import 'user_registration_list.model.dart';

class UserRegistrationListScene extends StatefulWidget {
  static final routes = {"/user-registration": canonicalRoute};

  static final canonicalRoute = CanonicalRoute(
    "user-registration",
    (context, settings, params) => SceneShell(
      title: "Usuários",
      actionBarBuilder: (context) {
        final model = SceneShellState.of(context).shared.model;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 160.0,
              child: ButtonCell(
                precedence: ButtonPrecedence.primary,
                label: "Novo usuário",
                cell: model.loading,
                onAction: (timestamp) {
                  Router.of(context).pushNamed(
                    "/user-registration/_/new",
                    arguments: {
                      "onBack": (BuildContext context) {
                        Router.of(context).pop();
                      },
                      "onSaved": ReferencedCallback(
                        callback: (context, reference, data) {
                          model["fetchQuery"].value = data["email"];
                          model.search(DateTime.now().millisecondsSinceEpoch);
                          Router.of(context).pop();
                        },
                      )
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      builder: (context) => UserRegistrationListScene(params: params),
    ),
  );

  UserRegistrationListScene({Key key, this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  _UserRegistrationListSceneState createState() => _UserRegistrationListSceneState();
}

class _UserRegistrationListSceneState extends SceneState<UserRegistrationListScene, UserRegistrationListModel> {
  @override
  createModel() => UserRegistrationListModel();

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;
    final mediaData = MediaQuery.of(context);

    final headerTextStyle = TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.w700,
    );

    return LoadingFuture(
      future: model.initialized,
      builder: (context) => Container(
        padding: theme.padding,
        margin: EdgeInsets.only(bottom: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextEntryCell(
              margin: EdgeInsets.only(left: theme.spacing, top: theme.spacing, right: theme.spacing),
              cell: model["fetchQuery"],
              label: "Digite sua busca",
              textInputAction: TextInputAction.search,
              icon: Icon(
                Icons.search,
                color: colorTheme.primary.canvas,
              ),
              onAction: (timestamp) {
                model.search(timestamp);
              },
            ),
            ModelCellWatcher(
              cell: model["fetchQuery"],
              interests: ["state"],
              builder: (context, cell, payloads) {
                final state = (payloads["state"] as String);

                return state == null || (payloads["state"] as String).isEmpty
                    ? SizedBox()
                    : Container(
                        margin: EdgeInsets.only(left: theme.spacing, right: theme.spacing, bottom: theme.spacing),
                        child: Wrap(
                          spacing: theme.spacing,
                          runSpacing: theme.spacing,
                          children: <Widget>[
                            CloseableChipCell(
                              cell: model["fetchQuery"],
                              label: "Busca por",
                              onAction: (timestamp) {
                                model["fetchQuery"].value = "";
                                model.search(timestamp);
                              },
                            ),
                          ],
                        ),
                      );
              },
            ),
            RichDataTableCell(
              margin: theme.margin,
              cell: model["fetchResult"],
              fetch: model.fetch,
              action: (entry) {
                Router.of(context).pushNamed(
                  "/user-registration/${entry.row["tid"]}/edit",
                  arguments: {
                    "onBack": (BuildContext context) {
                      Router.of(context).pop();
                    },
                    "onSaved": ReferencedCallback(
                      reference: entry,
                      callback: (context, reference, data) {
                        reference.row["accountUserRoles"] = {
                          "STORE": {
                            "#": [data["accountUserRole"]]
                          }
                        };

                        Router.of(context).pop();
                      },
                    ),
                    "onDeleted": ReferencedCallback(
                      reference: entry,
                      callback: (context, reference, data) {
                        final ref = (reference as RichDataTableActionEntry);
                        ref.result.removeAt(ref.index);

                        Router.of(context).pop();
                      },
                    ),
                  },
                );
              },
              rowDecoration: BoxDecoration(border: Border(top: BorderSide(width: 1.0, color: colorTheme.basis.weaker))),
              columns: {
                0: RichDataTableCellColumn(
                  columnWidth: FlexColumnWidth(),
                  columnVerticalAlignment: TableCellVerticalAlignment.top,
                  sort: "name",
                  builder: richDataTableCellColumnbBuilder(
                    title: "Usuário",
                    style: headerTextStyle,
                    padding: theme.margin,
                  ),
                ),
                1: RichDataTableCellColumn(
                  columnWidth: FixedColumnWidth(140.0),
                  columnVerticalAlignment: TableCellVerticalAlignment.top,
                  builder: richDataTableCellColumnbBuilder(
                    title: "Nível",
                    style: headerTextStyle,
                    padding: theme.margin,
                  ),
                )
              },
              rowBuilder: (context, entry) {
                return [
                  Container(
                    height: 58.0,
                    padding: theme.margin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          entry.row["name"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(flex: 1),
                        Text(
                          entry.row["email"],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: theme.margin,
                    child: Builder(
                      builder: (context) {
                        String role;
                        final accountUserRoles = entry.row["accountUserRoles"];

                        if (accountUserRoles != null) {
                          final storeEntryRole = entry.row["accountUserRoles"]["STORE"];

                          if (storeEntryRole != null) {
                            final storeTokenRole = storeEntryRole[Remote.storeToken] ?? storeEntryRole["*"] ?? storeEntryRole["#"];

                            if (storeTokenRole != null) {
                              role = userRoles[storeTokenRole[0]];
                            }
                          }
                        }
                        return Text(
                          role ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
