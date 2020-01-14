import '../../core/index.dart';
import '../../services/user_manager_service.dart';

class UserModel extends SceneModel {
  @override
  Future<void> init() async {
    build(() {
      C(
        key: "fetchQuery",
        label: "Busca",
        value: "",
        constraints: [minLengthConstraint(0)],
      );

      C(
        key: "fetchResult",
        value: null,
        constraints: [],
      );

      C(
        key: "enabled",
        label: "Habilitado",
        value: false,
        constraints: [],
      );

      C(
        key: "options",
        label: "Opções",
        value: "1",
        state: {"1": "opt 1", "2": "opt 2"},
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
      await list(1);
    });
  }

  Future<void> list(int timestamp, {int offset = 0, int limit = 10}) async {}
}
