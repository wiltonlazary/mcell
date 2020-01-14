import 'core/index.dart';
import 'scenes/login/login.scene.dart';
import 'scenes/home/home.scene.dart';
import 'scenes/user/user.scene.dart';
import 'scenes/user_registration/handler/user_registration_handler.scene.dart';
import 'scenes/user_registration/list/user_registration_list.scene.dart';

Future<void> initRoutes() async {
  registerRoutes(LoginScene.routes);
  registerRoutes(UsersScene.routes);
  registerRoutes(UserRegistrationListScene.routes);
  registerRoutes(UserRegistrationHandlerScene.routes);
  registerRoutes(HomeScene.routes);
}
