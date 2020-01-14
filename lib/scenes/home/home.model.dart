import '../../core/index.dart';

class HomeModel extends SceneModel {
  @override
  Future<void> init() async {
    build(() {
      C(key: "counter", value: 0);
      C(key: "text", value: "min-3, max-5", constraints: [minLengthConstraint(3), maxLengthConstraint(5)]);
    });
  }
}
