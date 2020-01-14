import 'dart:async';
import 'package:flutter/foundation.dart';

class ModelCellSnapshot {
  ModelCellSnapshot(this.value, this.state, this.errors, this.loading);

  final dynamic value;
  final dynamic state;
  final int loading;
  final List<ModelConstraintValidationResult> errors;
}

class ModelMessage {
  final String short;
  final String long;
  ModelMessage(this.short, this.long);
}

typedef R ModelTransformer<T, R>(T value);

typedef bool ModelConstraintValidation(ModelCell cell, ModelCellSnapshot snapshot);

typedef VoidCallback ModelCellOnInit(ModelCell cell);

typedef ModelMessage ConstraintValidationMessaging(ModelCell cell, ModelCellSnapshot snapshot);

class ModelConstraint {
  String name;
  ModelConstraintValidation validate;
  ConstraintValidationMessaging messaging;
  ModelConstraint({this.name, this.validate, this.messaging});
}

class ModelConstraintValidationResult {
  ModelConstraintValidationResult(
    this.constraint,
    this.message,
    this.cell,
    this.snapshot,
  );

  static final any = ModelConstraintValidationResult(null, null, null, null);
  static final anyErrors = [any];
  static final noErrors = <ModelConstraintValidationResult>[];

  final ModelConstraint constraint;
  final ModelMessage message;
  final ModelCell cell;
  final ModelCellSnapshot snapshot;
}

class ModelEvent {
  ModelEvent({this.source, this.interest, this.payload});

  final ModelCell source;
  final String interest;
  final dynamic payload;
}

class ModelCell {
  ModelCell({
    this.parent,
    this.label,
    dynamic value,
    dynamic state,
    List<ModelConstraint> constraints,
    ModelCellOnInit onInit,
  }) {
    this._value = value;
    this._state = state;
    this._constraints = constraints;

    if (onInit != null) {
      addDisposeListener(onInit(this));
    }
  }

  dynamic parent;
  String label;
  dynamic _state;
  dynamic _value;
  int _loading = 0;
  List<ModelConstraint> _constraints;
  List<ModelConstraintValidationResult> _errors = [];
  final _controller = StreamController<ModelEvent>.broadcast();
  Set<VoidCallback> _disposeListeners;

  Stream get stream => _controller.stream;

  dynamic content(String interest, {ModelTransformer transformer}) {
    switch (interest) {
      case "value":
        return transformer == null ? value : transformer(value);
        break;
      case "state":
        return transformer == null ? state : transformer(state);
        break;
      case "loading":
        return transformer == null ? loading : transformer(loading);
        break;
    }
  }

  addDisposeListener(VoidCallback listener) {
    if (_disposeListeners == null) {
      _disposeListeners = Set();
    }

    _disposeListeners.add(listener);
  }

  removeDisposeListener(VoidCallback listener) {
    if (_disposeListeners != null) {
      _disposeListeners.remove(listener);

      if (_disposeListeners.isEmpty) {
        _disposeListeners = null;
      }
    }
  }

  void dispose() {
    if (_disposeListeners != null) {
      _disposeListeners.forEach((it) {
        it();
      });

      _disposeListeners = null;
    }

    _controller.close();
    _value = null;
    _state = null;
    _errors = null;
  }

  dispatch({String interest, dynamic payload}) {
    if (!_controller.isClosed) {
      _controller.add(ModelEvent(source: this, interest: interest, payload: payload));
    }
  }

  dispatchEvent(ModelEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  VoidCallback subscribe({onEvent(ModelEvent event), List<String> interests}) {
    final filter = interests == null ? null : interests.toSet();

    final subscription = filter == null
        ? _controller.stream.listen((event) => onEvent(event))
        : _controller.stream.where((event) => filter.contains(event.interest)).listen((event) => onEvent(event));

    return () {
      subscription.cancel();
    };
  }

  List<ModelConstraintValidationResult> validate() {
    List<ModelConstraintValidationResult> result = check(snapshot);
    errors = result;
    return result;
  }

  List<ModelConstraintValidationResult> check(ModelCellSnapshot snapshot) {
    List<ModelConstraintValidationResult> result;

    if (_constraints == null) {
      result = [];
    } else {
      result = _constraints
          .map((it) {
            return it.validate(this, snapshot) ? null : ModelConstraintValidationResult(it, it.messaging(this, snapshot), this, snapshot);
          })
          .where((it) => it != null)
          .toList();
    }

    return result;
  }

  dynamic get value => _value;

  ModelCellSnapshot get snapshot => ModelCellSnapshot(value, state, errors, loading);

  set value(dynamic value) {
    _value = value;
    dispatch(interest: "value", payload: _value);
  }

  dynamic get state => _state;

  set state(dynamic state) {
    _state = state;
    dispatch(interest: "state", payload: _state);
  }

  mutate(List<String> interests, body(ModelCell cell)) {
    body(this);

    interests.forEach((interest) {
      switch (interest) {
        case "value":
          dispatch(interest: "value", payload: _value);
          break;
        case "state":
          dispatch(interest: "state", payload: _state);
          break;
        case "loading":
          dispatch(interest: "loading", payload: _loading);
          break;
      }
    });
  }

  int get loading => _loading;

  set loading(int loading) {
    _loading = loading;
    dispatch(interest: "loading", payload: _loading);
  }

  List<ModelConstraintValidationResult> get errors => _errors;

  set errors(List<ModelConstraintValidationResult> errors) {
    _errors = errors;
    dispatch(interest: "errors", payload: _errors);
  }

  setValidationMessage(String short, [String long]) {
    errors = [ModelConstraintValidationResult(null, ModelMessage(short, long), this, snapshot)];
  }
}

abstract class ModelNode extends ModelCell {
  ModelData model;

  ModelNode({
    this.model,
    dynamic parent,
    dynamic value,
    String label,
    List<ModelConstraint> constraints,
    ModelCellOnInit onInit,
  }) : super(
          parent: parent,
          value: value,
          label: label,
          constraints: constraints,
          onInit: onInit,
        );

  int get length;

  ModelCell call(dynamic key);

  ModelCell operator [](dynamic key);

  operator []=(dynamic key, dynamic element);

  bool containsKey(dynamic key);

  dynamic remove(dynamic key);

  void forEach(List<dynamic> path, Function(List<dynamic> path, dynamic key, ModelCell it) callback);

  void forAll(List<dynamic> path, Function(List<dynamic> path, dynamic key, ModelCell it) callback);

  Iterable<dynamic> get entries;
}

class ModelMap extends ModelNode {
  ModelMap({
    ModelData model,
    dynamic parent,
    String label,
    Map<String, dynamic> value,
    List<ModelConstraint> constraints,
    ModelCellOnInit onInit,
  }) : super(
          model: model,
          parent: parent,
          label: label,
          value: value ?? Map<String, dynamic>(),
          constraints: constraints,
          onInit: onInit,
        );

  @override
  int get length => _value.length;

  @override
  void dispose() {
    _value.values.forEach((it) => it.dispose());
    super.dispose();
  }

  @override
  ModelCell call(dynamic key) => _value[key];

  @override
  ModelCell operator [](dynamic key) => _value[key];

  @override
  operator []=(dynamic key, dynamic element) => _value[key] = element;

  @override
  bool containsKey(dynamic key) => _value.containsKey(key);

  @override
  ModelCell remove(dynamic key) => _value.remove(key);

  @override
  Iterable<ModelCell> get entries => _value.entries;

  @override
  void forEach(List<dynamic> path, Function(List<dynamic> path, dynamic key, ModelCell it) callback) {
    _value.forEach((key, it) {
      callback(path, key, it);
    });
  }

  @override
  void forAll(List<dynamic> path, Function(List<dynamic> path, dynamic key, ModelCell it) callback) {
    _value.forEach((key, it) {
      callback(path, key, it);

      if (it is ModelNode) {
        it.forAll([...path, key], callback);
      }
    });
  }
}

class ModelList extends ModelNode {
  ModelList({
    ModelData model,
    dynamic parent,
    String label,
    List<dynamic> value,
    List<ModelConstraint> constraints,
    ModelCellOnInit onInit,
  }) : super(
          model: model,
          parent: parent,
          label: label,
          value: value ?? [],
          constraints: constraints,
          onInit: onInit,
        );

  @override
  int get length => _value.length;

  @override
  void dispose() {
    _value.forEach((it) => it.dispose());
    super.dispose();
  }

  @override
  ModelCell call(dynamic key) => _value[key];

  @override
  ModelCell operator [](dynamic key) => _value[key];

  @override
  operator []=(dynamic key, dynamic element) {
    if (key == _value.length) {
      _value.add(element);
    } else {
      _value[key] = element;
    }
  }

  @override
  bool containsKey(dynamic key) => _value.containsKey(key);

  @override
  dynamic remove(dynamic key) => _value.remove(key);

  @override
  Iterable<dynamic> get entries => _value;

  @override
  void forEach(List<dynamic> path, Function(List<dynamic> path, dynamic key, ModelCell it) callback) {
    for (int key; key < _value.length; key++) {
      callback(path, key, _value[key]);
    }
  }

  @override
  void forAll(List<dynamic> path, Function(List<dynamic> path, dynamic key, ModelCell it) callback) {
    for (int key = 0; key < _value.length; key++) {
      final it = _value[key];
      callback(path, key, it);

      if (it is ModelNode) {
        it.forAll([...path, key], callback);
      }
    }
  }
}

//OBS: I'm forced to create a lot of junk because of the terrible,
//     inexpressive and antiquated dart language,
//     i miss Kotlin so much ;( #DartLangIsJunk
class _ModelBuilder {
  ModelData model;
  ModelNode _node;
  dynamic _key;

  _ModelBuilder(this.model) {
    _node = model.node;
  }

  ModelCell C(dynamic key, [String label, dynamic value, dynamic state, List<ModelConstraint> constraints, ModelCellOnInit onInit]) {
    final cellKey = key != null ? key : (_node is ModelList ? _node.length : _node.length.toString());
    final cell = ModelCell(parent: _node, label: label, value: value, state: state, constraints: constraints, onInit: onInit);
    _node[cellKey] = cell;
    return cell;
  }

  dynamic M(dynamic key, String label, body(ModelNode node)) {
    final savedNode = _node;
    final savedKey = _key;
    _key = key != null ? key : (_node is ModelList ? _node.length : _node.length.toString());
    _node = ModelMap(model: model, parent: savedNode, label: label);
    final result = _node;
    savedNode[key] = _node;
    body(_node);
    _node = savedNode;
    _key = savedKey;
    return result;
  }

  dynamic L(dynamic key, String label, body(ModelNode node)) {
    final savedNode = _node;
    final savedKey = _key;
    _key = key != null ? key : (_node is ModelList ? _node.length : _node.length.toString());
    _node = ModelList(model: model, parent: savedNode, label: label);
    final result = _node;
    savedNode[key] = _node;
    body(_node);
    _node = savedNode;
    _key = savedKey;
    return result;
  }
}

class ModelData {
  List<ModelCell> _cells;
  ModelNode node;
  Set<VoidCallback> _disposeListeners;
  _ModelBuilder _builder; // Dart forced me to make this junk code.
  var _disposed = false;

  ModelCell C({dynamic key, String label, dynamic value, state: dynamic, List<ModelConstraint> constraints, ModelCellOnInit onInit}) =>
      _builder.C(key, label, value, state, constraints, onInit);

  dynamic M({dynamic key, String label, body(ModelNode node)}) => _builder.M(key, label, body);

  dynamic L({dynamic key, String label, body(ModelNode node)}) => _builder.L(key, label, body);

  bool get disposed => _disposed;

  ModelCell cell({
    String label,
    dynamic value,
    dynamic state,
    List<ModelConstraint> constraints,
    ModelCellOnInit onInit,
  }) {
    if (_cells == null) {
      _cells = [];
    }

    final cell = ModelCell(
      parent: this,
      label: label,
      value: value,
      state: state,
      constraints: constraints,
      onInit: onInit,
    );

    _cells.add(cell);
    return cell;
  }

  ModelCell call(dynamic key) {
    List<String> parts = key.split(".");
    var _node = node;
    var value;

    parts.forEach((it) {
      final el = _node is ModelMap ? _node[it] : _node[int.parse(it)];

      if (el == null || !(el is ModelNode)) {
        value = el;
        return;
      } else {
        _node = el;
      }
    });

    return value;
  }

  List<T> map<T>(T Function(List<dynamic> path, dynamic key, ModelCell it) transformer) {
    final result = <T>[];

    node.forAll([], (path, key, it) {
      result.add(transformer(path, key, it));
    });

    return result;
  }

  Map<String, dynamic> values() => Map.fromEntries(map((path, key, it) => MapEntry([...path, key].join("."), it.value)));

  Map<String, ModelCell> cells() => Map.fromEntries(map((path, key, it) => MapEntry([...path, key].join("."), it)));

  ModelCell operator [](dynamic key) => call(key);

  build(void block()) {
    if (node != null) {
      node.dispose();
    }

    node = ModelMap(model: this);
    _builder = _ModelBuilder(this);
    block();
    _builder = null;
  }

  addDisposeListener(VoidCallback listener) {
    if (_disposeListeners == null) {
      _disposeListeners = Set();
    }

    _disposeListeners.add(listener);
  }

  removeDisposeListener(VoidCallback listener) {
    if (_disposeListeners != null) {
      _disposeListeners.remove(listener);

      if (_disposeListeners.isEmpty) {
        _disposeListeners = null;
      }
    }
  }

  void dispose() {
    _disposed = true;

    _disposeListeners?.forEach((it) {
      it();
    });

    _cells?.forEach((it) {
      it.dispose();
    });

    node?.dispose();
  }

  Map<String, List<ModelConstraintValidationResult>> validate() {
    Map<String, List<ModelConstraintValidationResult>> result = {};

    node.forAll([], (path, key, it) {
      final vres = it.validate();

      if (vres.isNotEmpty) {
        result[[...path, key].map((it) => it.toString()).join(".")] = vres;
      }
    });

    return result;
  }

  Map<String, List<ModelConstraintValidationResult>> check() {
    Map<String, List<ModelConstraintValidationResult>> result = {};

    node.forAll([], (path, key, it) {
      final vres = it.check(it.snapshot);

      if (vres.isNotEmpty) {
        result[[...path, key].map((it) => it.toString()).join(".")] = vres;
      }
    });

    return result;
  }
}
