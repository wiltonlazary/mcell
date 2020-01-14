import 'package:flutter/material.dart';
import '../mcell.dart';

class ManagedCellWidgetStateCreatorResult {
  dynamic state;
  VoidCallback disposer;
  ManagedCellWidgetStateCreatorResult({this.state, this.disposer});
}

typedef Widget ManagedCellWidgetBuilder<T>(BuildContext context, dynamic state);

typedef ManagedCellWidgetStateCreatorResult ManagedCellWidgetStateCreator<T>(ModelCell cell, void update(f(dynamic state)));

typedef Widget ModelCellWatcherBuilder(BuildContext context, ModelCell cell, Map<String, dynamic> payloads);

class ManagedModelCellWidget extends StatefulWidget {
  final ModelCell cell;
  final ManagedCellWidgetBuilder builder;
  final ManagedCellWidgetStateCreator creator;

  ManagedModelCellWidget({Key key, this.cell, this.builder, this.creator}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ManagedModelCellWidgetState(cell: cell, builder: builder, creator: creator);
}

class _ManagedModelCellWidgetState<T> extends State<ManagedModelCellWidget> {
  ModelCell cell;
  final ManagedCellWidgetBuilder builder;
  VoidCallback _disposer;
  dynamic _state;

  _ManagedModelCellWidgetState({this.cell, this.builder, ManagedCellWidgetStateCreator creator}) {
    final res = creator(cell, update);
    _disposer = res.disposer;
    _state = res.state;
  }

  @override
  void dispose() {
    if (_disposer != null) {
      _disposer();
    }

    super.dispose();
  }

  void update(f(dynamic state)) {
    setState(() {
      f(_state);
    });
  }

  @override
  Widget build(BuildContext context) => builder(context, _state);
}

class ModelCellWatcher extends StatefulWidget {
  ModelCellWatcher({
    Key key,
    @required this.cell,
    @required this.builder,
    this.interests = const ["value"],
  }) : super(key: key);

  final ModelCell cell;
  final List<String> interests;
  final ModelCellWatcherBuilder builder;

  @override
  State<StatefulWidget> createState() => _ModelCellWatcherState();
}

class _ModelCellWatcherState extends State<ModelCellWatcher> {
  VoidCallback _unsubscriber;
  Map<String, dynamic> _payloadsToDispatchTmp;
  Map<String, dynamic> _payloadsToDispatch;

  @override
  initState() {
    super.initState();
    _payloadsToDispatch = {};

    widget.interests.forEach((it) {
      _payloadsToDispatch[it] = widget.cell.content(it);
    });

    _unsubscriber = widget.cell.subscribe(
      interests: widget.interests,
      onEvent: (event) {
        if (_payloadsToDispatchTmp == null) {
          _payloadsToDispatch = null;
          _payloadsToDispatchTmp = {};
          _payloadsToDispatchTmp[event.interest] = event.payload;

          Future.microtask(() {
            final _payloadsToDispatchLocal = _payloadsToDispatchTmp;
            _payloadsToDispatch = null;
            _payloadsToDispatchTmp = null;

            setState(() {
              _payloadsToDispatch = _payloadsToDispatchLocal;
            });
          });
        } else {
          _payloadsToDispatchTmp[event.interest] = event.payload;
        }
      },
    );
  }

  @override
  void dispose() {
    if (_unsubscriber != null) {
      _unsubscriber();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.cell, _payloadsToDispatch);
  }
}
