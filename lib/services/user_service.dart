import '../core/index.dart';
import '../core/remote.dart';

class UserService {
  static Future<dynamic> self() async {
    var self = Persistence.get('self');

    if (self != null) {
      return self;
    } else {
      self = (await Remote.get("api/ref/user/self"))["data"];
      await Persistence.put('self', self);
      return self;
    }
  }

  static Future<void> clearSelf() async {
    print("clear self");
    await Persistence.put('self', null);
  }
}
