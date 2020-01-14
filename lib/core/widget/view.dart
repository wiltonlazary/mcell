import 'package:flutter/material.dart';

import '../mcell.dart';
import '../remote.dart';
import '../routing.dart';
import '../theme.dart';
import 'stage.dart';
import 'toast.dart';
import 'util.dart';

abstract class ViewModel extends ModelData {
  ViewState _state;
  Map<String, dynamic> params;
  Future<void> initialized;
  ModelCell _loading;

  ModelCell get loading {
    if (_loading == null) {
      _loading = ModelCell(value: 0);
    }

    return _loading;
  }

  ViewState get state => _state;

  @override
  void dispose() {
    if (_loading != null) _loading.dispose();
    super.dispose();
  }

  BuildContext get context => _state.context;

  Future<void> init();

  Future<dynamic> action({
    int timestamp,
    Map<String, dynamic> values,
    Future<dynamic> before(int timestamp),
    Future<dynamic> after(int timestamp),
    Future<dynamic> body(Map<String, dynamic> values),
  }) async {
    _state.stageState.incLoading(timestamp);
    loading.loading = timestamp;

    try {
      if (before != null) await before(timestamp);
      await body(values);
    } on ValidationRemoteException catch (e) {
      e.fields.forEach((key, value) {
        ModelCell cell = this[key];

        if (cell != null) {
          cell.errors = List<ModelConstraintValidationResult>.from(
            value
                .expand(
                  (it) => it.map(
                    (result) => ModelConstraintValidationResult(
                      null,
                      ModelMessage(result['message']['short'], result['message']['long']),
                      cell,
                      values == null ? cell.snapshot : ModelCellSnapshot(values[key], cell.state, cell.errors, cell.loading),
                    ),
                  ),
                )
                .toList(),
          );
        }
      });

      Toast.warn("Dados de validação reportados!");
    } on UnauthorizedRemoteException catch (e, _) {
      Router.of(context).pushReplacementNamed("/login");
    } on DuplicatedEntryRemoteException catch (e, _) {
      Toast.warn("O registro já existe!");
    } on RemoteConnectionException catch (e, _) {
      Toast.error("Sem conexão!");
    } catch (e, s) {
      Toast.exception(e, s);
    } finally {
      await Future.delayed(Duration(milliseconds: 300 - (DateTime.now().millisecondsSinceEpoch - timestamp)));
      if (after != null) await after(timestamp);
      loading.loading = 0;
      _state.stageState.decLoading(timestamp);
    }
  }
}

abstract class ViewState<T extends StatefulWidget, M extends ViewModel> extends State<T> {
  StageState stageState;
  CoreTheme theme;
  final focusEntries = <String, FocusEntry>{};
  var _focusBuilded = false;
  FocusEntry firstFocusEntry;
  FocusEntry lastFocusEntry;
  M model;
  Set<VoidCallback> _disposeListeners;
  bool _disposed = false;

  M createModel();

  bool get disposed => _disposed;

  @override
  void initState() {
    super.initState();
    stageState = StageState.of(context);
    theme = stageState.theme;
    model = createModel();
    model._state = this;
    model.params = (widget as dynamic).params;

    model.initialized = model.init().catchError((e) {
      print("exception: model.init");
      Toast.exception(e);
    });
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

  FocusEntry focus(String key) {
    if (_focusBuilded || focusEntries.containsKey(key)) {
      return focusEntries[key];
    } else {
      final entry = FocusEntry(node: FocusNode(), prev: lastFocusEntry);
      focusEntries[key] = entry;

      if (firstFocusEntry == null) {
        firstFocusEntry = entry;
      }

      if (lastFocusEntry != null) {
        lastFocusEntry.next = entry;
      }

      lastFocusEntry = entry;
      return entry;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    focusEntries.values.forEach((it) => it.dispose());

    if (_disposeListeners != null) {
      _disposeListeners.forEach((it) {
        it();
      });
    }

    model.dispose();
    super.dispose();
    model = null;

    print("disposed: view");
  }

  Widget builder(Widget build(BuildContext context)) {
    final res = build(context);

    if (!_focusBuilded) {
      _focusBuilded = true;

      if (firstFocusEntry != null) {
        firstFocusEntry.prev = lastFocusEntry;
        lastFocusEntry.next = firstFocusEntry;
      }
    }

    return res;
  }
}
