import '../../core/index.dart';
import '../../services/login_service.dart';

class LoginModel extends ViewModel {
  @override
  Future<void> init() async {
    build(() {
      C(
        key: "email",
        label: "Email",
        value: "",
        constraints: [emailConstraint(), maxLengthConstraint(255)],
      );
      C(
        key: "password",
        label: "Senha",
        value: "",
        constraints: [minLengthConstraint(6), maxLengthConstraint(255)],
      );
    });
  }

  submit(int timestamp) {
    action(
      timestamp: timestamp,
      values: values(),
      body: (values) async {
        try {
          final validations = validate();

          if (validations.isEmpty) {
            final res = await LoginService.login(values["email"], values["password"]);

            if (!disposed) {
              StageState.of(context).update();
              final router = Router.of(context);
              final routeName = router.current().settings.name;
              router.pushNamedAndRemoveUntilRoot(routeName == "/login" ? "/user-registration" : routeName);
            }
          } else {
            Toast.warn(validations.values.first[0].message.long);
          }
        } on UnauthorizedRemoteException {
          Toast.warn("Email ou senha incorretos!");
        }
      },
    );
  }
}
