import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'remote.dart';
import 'plugin.dart';
import 'widget/stage.dart';

class RouteArguments {
  const RouteArguments(this.canonical, this.arguments);

  final String canonical;
  final dynamic arguments;
}

typedef Widget WidgetRoute(BuildContext context, RouteSettings settings, Map<String, dynamic> params);

class CanonicalRoute {
  CanonicalRoute(this.canonical, this.route);

  final String canonical;
  final WidgetRoute route;
}

Map<String, String> parseQueryString(String query) {
  var search = RegExp('([^&=]+)=?([^&]*)');
  var params = Map<String, String>();

  if (query.startsWith('?')) query = query.substring(1);

  decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

  for (Match match in search.allMatches(query)) {
    String key = decode(match.group(1));
    String value = decode(match.group(2));
    params[key] = value;
  }

  return params;
}

class NavigatorRouter {
  static Route current(NavigatorState navigatorState) {
    Route _route;

    navigatorState.popUntil((route) {
      _route = route;
      return true;
    });

    return _route;
  }

  @optionalTypeArgs
  static Future<T> pushState<T>(String routeName) async {
    return kIsWeb ? await pluginChannel.invokeMethod('hash', routeName) : null;
  }

  @optionalTypeArgs
  static Future<bool> pop<T extends Object>(NavigatorState navigatorState, [T result]) async {
    navigatorState.pop();
    Route _route;

    navigatorState.popUntil((route) {
      _route = route;
      return true;
    });

    if (_route != null) {
      await pushState(_route.settings.name);
    }

    return _route != null;
  }

  static String normalizeRouteName(String routeName) => "/" + routeName.substring(1).replaceAll("/", "\\");

  @optionalTypeArgs
  static Future<T> push<T extends Object>(NavigatorState navigatorState, Route<T> route) {
    return navigatorState.push(route);
  }

  @optionalTypeArgs
  static Future<T> pushNamedAndRemoveUntil<T>(
    NavigatorState navigatorState,
    String routeName,
    RoutePredicate predicate, {
    Object arguments,
  }) async {
    await pushState(routeName);

    return navigatorState.pushNamedAndRemoveUntil<T>(
      normalizeRouteName(routeName),
      predicate,
      arguments: arguments,
    );
  }

  @optionalTypeArgs
  static Future<T> pushNamedAndRemoveUntilRoot<T>(NavigatorState navigatorState, String routeName, {Object arguments}) async {
    navigatorState.popUntil((route) {
      if (route.settings.name == "/") {
        return true;
      } else {
        return false;
      }
    });

    return pushNamed(navigatorState, routeName, arguments: arguments);
  }

  @optionalTypeArgs
  static Future<T> pushNamed<T>(NavigatorState navigatorState, String routeName, {Object arguments}) async {
    await pushState(routeName);

    return navigatorState.pushNamed<T>(
      normalizeRouteName(routeName),
      arguments: arguments,
    );
  }

  @optionalTypeArgs
  static Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
    NavigatorState navigatorState,
    String routeName, {
    TO result,
    Object arguments,
  }) async {
    await pushState(routeName);

    return navigatorState.pushReplacementNamed<T, TO>(
      normalizeRouteName(routeName),
      arguments: arguments,
    );
  }
}

class Router {
  Router(this.context, this.navigatorKey);
  final BuildContext context;
  GlobalKey<NavigatorState> navigatorKey;

  static Router of(BuildContext context) {
    final stageState = StageState.of(context);
    return Router(context, stageState.navigatorKey);
  }

  Route current() {
    Route _route;

    Navigator.popUntil(context, (route) {
      _route = route;
      return true;
    });

    return _route;
  }

  @optionalTypeArgs
  Future<T> pushState<T>(String routeName) => NavigatorRouter.pushState(routeName);

  @optionalTypeArgs
  Future<bool> pop<T extends Object>([T result]) => NavigatorRouter.pop(navigatorKey.currentState, result);

  @optionalTypeArgs
  Future<T> push<T extends Object>(Route<T> route) => NavigatorRouter.push(navigatorKey.currentState, route);

  @optionalTypeArgs
  Future<T> pushNamedAndRemoveUntil<T>(String routeName, RoutePredicate predicate, {Object arguments}) =>
      NavigatorRouter.pushNamedAndRemoveUntil(navigatorKey.currentState, routeName, predicate, arguments: arguments);

  @optionalTypeArgs
  Future<T> pushNamedAndRemoveUntilRoot<T>(String routeName, {Object arguments}) =>
      NavigatorRouter.pushNamedAndRemoveUntilRoot(navigatorKey.currentState, routeName, arguments: arguments);

  @optionalTypeArgs
  Future<T> pushNamed<T>(String routeName, {Object arguments}) =>
      NavigatorRouter.pushNamed(navigatorKey.currentState, routeName, arguments: arguments);

  @optionalTypeArgs
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    Object arguments,
  }) =>
      NavigatorRouter.pushReplacementNamed(navigatorKey.currentState, routeName, result: result, arguments: arguments);
}

List<Map<List<String>, CanonicalRoute>> _routes = [];

registerRoutes(Map<String, CanonicalRoute> routes) {
  _routes.add({...routes.map((key, value) => MapEntry((key[0] == "/" ? key.substring(1) : key).split("/"), value))});
}

class MatchRouteResult {
  final CanonicalRoute canonicalRoute;
  final Map<String, dynamic> params;

  MatchRouteResult(this.canonicalRoute, this.params);
}

//TODO: improve match algorithm
MatchRouteResult _matchRoute(List<String> routeParts, Map<List<String>, CanonicalRoute> routes) {
  CanonicalRoute canonicalRoute;
  Map<String, dynamic> params;

  for (final it in routes.entries.toList()) {
    final keyParts = it.key;
    final gathered = <String, dynamic>{};

    if (keyParts.length == routeParts.length) {
      var matched = true;

      for (int i = 0; i < keyParts.length; i++) {
        final keyPart = keyParts[i];
        final routePart = routeParts[i];

        if (keyPart.length > 0 && keyPart[0] == ":") {
          gathered[keyPart.substring(1)] = routePart;
        } else if (keyPart != routePart) {
          matched = false;
          break;
        }
      }

      if (matched) {
        canonicalRoute = it.value;
        params = gathered;
        break;
      }
    }
  }

  return canonicalRoute == null ? null : MatchRouteResult(canonicalRoute, params);
}

RouteFactory routeFactory({@required CanonicalRoute loginCanonicalRoute, @required CanonicalRoute defaultCanonicalRoute}) {
  CanonicalRoute intercept(CanonicalRoute canonicalRoute) {
    return Remote.token == null ? loginCanonicalRoute : canonicalRoute;
  }

  return (RouteSettings settings) {
    final requestParts = settings.name.split("?");
    final routeParts = requestParts[0].substring(1).replaceAll("/", "\\").split("\\");
    print("route for: ${settings.name} => $routeParts");

    if (settings.name == "/") {
      final routeSettings = RouteSettings(
        name: settings.name.replaceAll("\\", "/"),
        arguments: RouteArguments(defaultCanonicalRoute.canonical, settings.arguments),
        isInitialRoute: true,
      );

      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return intercept(defaultCanonicalRoute)
              .route(context, routeSettings, requestParts.length == 1 ? {} : parseQueryString(requestParts[1]));
        },
      );
    } else {
      MatchRouteResult matchRouteResult;

      for (final it in _routes) {
        matchRouteResult = _matchRoute(routeParts, it);
        if (matchRouteResult != null) break;
      }

      matchRouteResult = matchRouteResult == null
          ? MatchRouteResult(intercept(defaultCanonicalRoute), {})
          : MatchRouteResult(intercept(matchRouteResult.canonicalRoute), matchRouteResult.params);

      final routeSettings = RouteSettings(
        name: settings.name.replaceAll("\\", "/"),
        arguments: RouteArguments(matchRouteResult.canonicalRoute.canonical, settings.arguments),
        isInitialRoute: true,
      );

      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) {
          return matchRouteResult.canonicalRoute.route(
            context,
            routeSettings,
            requestParts.length == 1 ? matchRouteResult.params : {...matchRouteResult.params, ...parseQueryString(requestParts[1])},
          );
        },
      );
    }
  };
}
