import '../../../core/index.dart';
import '../../../services/user_manager_service.dart';

class UserRegistrationListModel extends SceneModel {
  dynamic fetchParams = {};

  @override
  Future<void> init() async {
    build(() {
      fetchParams["q"] = params["q"] ?? "";
      fetchParams["limit"] = params["limit"]?.toString()?.toInt() ?? 10;
      fetchParams["sortBy"] = params["sortBy"] ?? "name";

      C(
        key: "fetchQuery",
        label: "Busca",
        value: fetchParams["q"],
        state: fetchParams["q"],
        constraints: [maxLengthConstraint(255)],
      );

      C(
        key: "fetchResult",
        value: null,
      );
    });

    await Future.microtask(() async {
      await search(1, offset: params["offset"]?.toString()?.toInt() ?? 0);
    });
  }

  Future<void> search(int timestamp, {int offset = 0}) async {
    final fetchQueryCell = node["fetchQuery"];
    final validations = fetchQueryCell.validate();

    if (validations.isEmpty) {
      final q = fetchQueryCell.value;
      fetchParams["q"] = q;
      fetchParams["offset"] = offset;

      await list(timestamp, fetchParams, onSuccess: () {
        fetchQueryCell.state = q;
      });
    } else {
      Toast.warn(validations.first.message.long);
    }
  }

  Future<void> fetch(int timestamp, {int offset, int limit, String sortBy}) async {
    fetchParams["offset"] = offset;
    fetchParams["limit"] = limit;
    fetchParams["sortBy"] = sortBy;
    await list(timestamp, fetchParams);
  }

  Future<void> list(int timestamp, Map<dynamic, dynamic> params, {Function onSuccess, Function onFailure}) async {
    state.scrollToTop();
    final fetchQueryCell = node["fetchQuery"];
    final fetchResultCell = node["fetchResult"];

    await action(
      timestamp: timestamp,
      before: (_) async {
        fetchQueryCell.loading = timestamp;
        fetchResultCell.loading = timestamp;
      },
      after: (_) async {
        fetchQueryCell.loading = 0;
        fetchResultCell.loading = 0;
      },
      body: (_) async {
        try {
          final value = await UserManagerService.list(params);

          if (!disposed) {
            fetchResultCell.value = value;
            fetchResultCell.errors = ModelConstraintValidationResult.noErrors;
            Router.of(context).pushState("/user-registration?${paramsToString(params)}");

            if (onSuccess != null) {
              onSuccess();
            }
          }
        } catch (e) {
          if (!disposed) {
            fetchResultCell.errors = ModelConstraintValidationResult.anyErrors;

            if (onFailure != null) {
              onFailure();
            }
          }

          throw e;
        }
      },
    );
  }
}
