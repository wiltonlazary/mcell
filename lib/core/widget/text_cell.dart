import 'package:flutter/material.dart';
import 'widget.dart';
import '../mcell.dart';

ModelCellWatcher TextCell({ModelCell cell, ModelTransformer<dynamic, String> transin, TextStyle style}) {
  return ModelCellWatcher(
    cell: cell,
    interests: const ["value"],
    builder: (context, cell, event) {
      final text = Text(
        transin == null ? (cell.value?.toString() ?? "") : transin(cell.value),
        style: style == null ? Theme.of(context).textTheme.display1 : style,
      );

      return text;
    },
  );
}
