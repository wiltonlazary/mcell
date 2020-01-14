import '../../../core/index.dart';
import '../../../services/user_manager_service.dart';
import '../user.dart';

class UserRegistrationHandlerModel extends SceneModel {
  UserRegistrationHandlerModel({this.onSaved, this.onDeleted});

  final ReferencedCallback onSaved;
  final ReferencedCallback onDeleted;
  final uuid = Uuid();
  ModelCell store;

  @override
  Future<void> init() async {
    store = cell(
      value: {
        "tid": params["tid"],
        "action": params["action"],
      },
    );

    build(() {
      C(
        key: "accountUserRole",
        label: "Role",
        value: "OPERATOR",
        state: userRoles,
        constraints: [],
      );

      C(
        key: "name",
        label: "Nome",
        value: "",
        constraints: [minLengthConstraint(3)],
      );

      C(
        key: "email",
        label: "Email",
        value: "lastprofane+dev@gmail.com",
        constraints: [emailConstraint(), maxLengthConstraint(255)],
      );
    });

    await Future.microtask(() async {
      await load(1);
    });
  }

  bool hasTid() => store.value["tid"] != "_";

  Future<void> load(int timestamp) async {
    final tid = store.value["tid"];

    if (tid != "_") {
      await action(
        timestamp: timestamp,
        body: (_) async {
          final res = (await UserManagerService.fetch(tid: tid))["data"];

          if (!disposed) {
            this["name"].value = res["name"];
            this["email"].value = res["email"];
            this["accountUserRole"].value = (res["accountUserRoles"]["STORE"] as Map<String, dynamic>).entries.first.value[0];
          }
        },
      );
    }
  }

  Future<void> save(int timestamp) async {
    await action(
      timestamp: timestamp,
      body: (_) async {
        final tid = store.value["tid"];
        final validations = this.validate();

        if (validations.isEmpty) {
          try {
            final data = tid == "_"
                ? {
                    "email": this["email"].value,
                    "name": this["name"].value,
                    "password": "#" + sha256.convert(utf8.encode(uuid.v4())).toString(),
                    "accountUserRole": this["accountUserRole"].value,
                  }
                : {"accountUserRole": this["accountUserRole"].value};

            final res = await UserManagerService.save(tid, data);

            if (!disposed) {
              if (tid == "_") {
                store.mutate(["value"], (cell) {
                  cell.value["tid"] = res["data"]["tid"];
                });
              }

              if (onSaved == null) {
                Router.of(context).pushNamedAndRemoveUntilRoot("/user-registration");
              } else {
                onSaved.callback(context, onSaved.reference, data);
              }
            }

            Toast.success("Usuário salvo com sucesso!");
          } on DuplicatedEntryRemoteException catch (_) {
            this["email"].setValidationMessage("já cadastrado como usuário");
            Toast.warn("Usuário já existe!");
          }
        } else {
          Toast.warn(validations.values.first[0].message.long);
        }
      },
    );
  }

  Future<void> delete(int timestamp) async {
    await action(
      timestamp: timestamp,
      body: (_) async {
        final tid = store.value["tid"];
        final res = await UserManagerService.delete(tid);

        if (onDeleted == null) {
          Router.of(context).pushNamedAndRemoveUntilRoot("/user-registration");
        } else {
          onDeleted.callback(context, onSaved.reference, null);
        }
      },
    );
  }
}
