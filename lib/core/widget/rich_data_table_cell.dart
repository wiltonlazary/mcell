import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../lang/index.dart';
import '../future.dart';
import '../mcell.dart';
import '../theme.dart';
import 'icon_button_cell.dart';
import 'loading.dart';

richDataTableCellColumnbBuilder({String title, TextStyle style, EdgeInsets padding}) {
  return (
    BuildContext context,
    RichDataTableCellColumnSortState sortState,
    Future<void> sortAction(bool ascending),
  ) {
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: sortAction == null
          ? null
          : () {
              sortAction(!sortState.ascending);
            },
      child: Container(
        padding: padding,
        child: Row(
          children: <Widget>[
            Text(
              title,
              style: style,
            ),
            if (sortState != null && sortState != RichDataTableCellColumnSortState.none)
              Container(
                width: 14,
                height: 14,
                child: Stack(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.sortUp,
                      size: 14,
                      color: !sortState.sorted
                          ? colorTheme.basis.weak
                          : sortState.ascending ? colorTheme.basis.canvasFace : colorTheme.basis.weak,
                    ),
                    Icon(
                      FontAwesomeIcons.sortDown,
                      size: 14,
                      color: !sortState.sorted
                          ? colorTheme.basis.weak
                          : sortState.ascending ? colorTheme.basis.weak : colorTheme.basis.canvasFace,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  };
}

class RichDataTableCellColumnSortState {
  static const none = RichDataTableCellColumnSortState();

  const RichDataTableCellColumnSortState({this.sorted = false, this.ascending = false});

  final bool sorted;
  final bool ascending;
}

class RichDataTableCellColumn {
  RichDataTableCellColumn({
    this.sort,
    this.columnWidth,
    this.columnVerticalAlignment,
    @required this.builder,
  });

  final String sort;
  final TableColumnWidth columnWidth;
  final TableCellVerticalAlignment columnVerticalAlignment;
  final RichDataTableCellColumnBuilder builder;
}

typedef Widget RichDataTableCellColumnBuilder(
  BuildContext context,
  RichDataTableCellColumnSortState sortState,
  Future<void> sortAction(bool ascending),
);

class RichDataTableActionEntry {
  RichDataTableActionEntry(this.result, this.index, this.row);

  final List<dynamic> result;
  final int index;
  final dynamic row;
}

typedef RichDataTableAction(RichDataTableActionEntry entry);

typedef List<Widget> RichDataTableRowBuilder(BuildContext context, RichDataTableActionEntry entry);

class RichDataTableCell extends StatefulWidget {
  RichDataTableCell({
    @required this.cell,
    @required this.columns,
    @required this.rowBuilder,
    this.action,
    this.textBaseline,
    this.textDirection,
    this.border,
    this.fetch,
    this.headerDecoration,
    this.rowDecoration,
    this.emptyContent,
    this.margin,
    this.constraints,
    this.defaultColumnWidth = const FlexColumnWidth(1.0),
    this.defaultVerticalAlignment = TableCellVerticalAlignment.top,
    this.scrollAction,
  });

  final ModelCell cell;
  final Map<int, RichDataTableCellColumn> columns;
  final RichDataTableRowBuilder rowBuilder;
  final RichDataTableAction action;
  final Fetch fetch;
  final VoidCallback scrollAction;

  final TableColumnWidth defaultColumnWidth;
  final TextDirection textDirection;
  final TableBorder border;
  final TableCellVerticalAlignment defaultVerticalAlignment;
  final TextBaseline textBaseline;
  final BoxDecoration headerDecoration;
  final BoxDecoration rowDecoration;
  final Widget emptyContent;
  final EdgeInsets margin;
  final BoxConstraints constraints;

  @override
  _RichDataTableCellState createState() => _RichDataTableCellState();
}

class _RichDataTableCellState extends State<RichDataTableCell> {
  VoidCallback disposer;
  bool hasErrors;
  FocusNode subjectFocusNode;
  dynamic dataSource;
  Map<int, TableColumnWidth> columnWidths = {};
  Map<int, TableCellVerticalAlignment> columnVerticalAlignments = {};

  @override
  void initState() {
    super.initState();
    subjectFocusNode = FocusNode();
    hasErrors = widget.cell.errors.isNotEmpty;
    dataSource = widget.cell.value;

    widget.columns.forEach((index, column) {
      if (column.columnWidth != null) {
        columnWidths[index] = column.columnWidth;
      }

      if (column.columnVerticalAlignment != null) {
        columnVerticalAlignments[index] = column.columnVerticalAlignment;
      }
    });

    final unsubscribe = widget.cell.subscribe(
      interests: ["value", "errors", "loading", "fetch"],
      onEvent: (event) {
        switch (event.interest) {
          case "value":
            setState(() {
              dataSource = event.payload;
            });
            break;
          case "errors":
            if (event.payload.isNotEmpty || hasErrors) {
              setState(() {
                hasErrors = event.payload.isNotEmpty;
              });
            }
            break;
          case "loading":
            setState(() {/* Silent */});
            break;
          case "fetch":
            setState(() {/* Silent */});
            break;
        }
      },
    );

    disposer = () {
      unsubscribe();
    };
  }

  @override
  void dispose() {
    if (disposer != null) disposer();
    subjectFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;

    buildEmpty() => LayoutBuilder(
          builder: (context, constraints) {
            print("constraints: ${constraints.minWidth} / ${constraints.minWidth}");

            return Container(
              child: Center(
                child: Text("Sem resultado para exibir!"),
              ),
            );
          },
        );

    buildLoading() => Center(
          child: Container(
            width: 300.0,
            height: 300.0,
            child: Center(
              child: Loading(),
            ),
          ),
        );

    Widget buildPaginator() {
      final data = dataSource["data"];
      final offset = data["offset"];
      final limit = data["limit"];
      final total = dataSource["data"]["total"];
      final length = data["result"].length;
      final sortBy = data["sortBy"];
      final end = offset + length;

      return Container(
        padding: EdgeInsets.only(top: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (offset > 0)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButtonCell(
                    cell: widget.cell,
                    icon: Icon(Icons.first_page, size: 40.0, color: colorTheme.basis.canvasFace),
                    onAction: (timestamp) {
                      widget.fetch(timestamp, offset: 0, limit: limit, sortBy: sortBy);
                    },
                  ),
                ),
              ),
            IconButtonCell(
              cell: widget.cell,
              icon: Icon(Icons.navigate_before, size: 40.0, color: colorTheme.basis.canvasFace),
              onAction: offset <= 0
                  ? null
                  : (timestamp) {
                      widget.fetch(timestamp, offset: offset - limit > 0 ? offset - limit : 0, limit: limit, sortBy: sortBy);
                    },
            ),
            Text(length == 0 ? "[-]" : "Registro${length > 1 ? "s" : ""} (${offset + 1} .. $end)"),
            IconButtonCell(
              cell: widget.cell,
              icon: Icon(Icons.navigate_next, size: 40.0, color: colorTheme.basis.canvasFace),
              onAction: length < limit || (total > 0 && end >= total)
                  ? null
                  : (timestamp) {
                      widget.fetch(timestamp, offset: end, limit: limit, sortBy: sortBy);
                    },
            ),
          ],
        ),
      );
    }

    buildDataTable() {
      final data = dataSource["data"];
      final length = data["result"].length;
      final offset = data["offset"];
      final limit = data["limit"];
      var sortBy = data["sortBy"].toString().split(",")[0];
      var sortByAscending = true;

      if (sortBy.startsWith("-")) {
        sortByAscending = false;
        sortBy = sortBy.substring(1);
      } else if (sortBy.startsWith("+")) {
        sortBy = sortBy.substring(1);
      }

      final sourceResult = (dataSource["data"]["result"] as List);

      return Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorTheme.basis.weaker, width: 1.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: length == 0
                ? Center(child: Text("Fim de registro."))
                : Table(
                    columnWidths: columnWidths,
                    defaultColumnWidth: widget.defaultColumnWidth,
                    defaultVerticalAlignment: widget.defaultVerticalAlignment,
                    textDirection: widget.textDirection,
                    border: widget.border,
                    textBaseline: widget.textBaseline,
                    children: [
                      TableRow(
                        decoration: widget.headerDecoration,
                        children: widget.columns.transform(
                          (index, column) {
                            final sortState = column.sort == null
                                ? RichDataTableCellColumnSortState.none
                                : (column.sort == sortBy
                                    ? RichDataTableCellColumnSortState(sorted: true, ascending: sortByAscending)
                                    : RichDataTableCellColumnSortState.none);

                            return column.builder(
                              context,
                              sortState,
                              column.sort == null
                                  ? null
                                  : (ascending) async {
                                      widget.fetch(
                                        DateTime.now().millisecondsSinceEpoch,
                                        offset: 0,
                                        limit: limit,
                                        sortBy: "${sortState.ascending ? "-" : ""}${column.sort}",
                                      );
                                    },
                            );
                          },
                        ),
                      ),
                      ...(dataSource["data"]["result"] as List).transformIndexed<TableRow>(
                        (index, row) => TableRow(
                          decoration: widget.rowDecoration,
                          children: widget
                              .rowBuilder(
                                context,
                                RichDataTableActionEntry(sourceResult, index, row),
                              )
                              .transform(
                                (item) => TableCell(
                                  verticalAlignment: !columnVerticalAlignments.containsKey(index) ? null : columnVerticalAlignments[index],
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    child: item,
                                    onTap: () => widget.action(
                                      RichDataTableActionEntry(sourceResult, index, row),
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (dataSource["data"]["total"] == -1 || dataSource["data"]["total"] > dataSource["data"]["limit"]) buildPaginator(),
        ],
      );
    }

    buildAbsorverAndLoading() => AbsorbPointer(
          absorbing: true,
          child: RawKeyboardListener(
            focusNode: subjectFocusNode,
            onKey: (event) {
              FocusScope.of(context).requestFocus(subjectFocusNode);
            },
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: 0.3,
                  child: buildDataTable(),
                ),
                buildLoading(),
              ],
            ),
          ),
        );

    return Container(
      margin: widget.margin,
      constraints: widget.constraints,
      child: dataSource == null || dataSource["data"]["total"] == 0
          ? widget.emptyContent ?? buildEmpty()
          : (widget.cell.loading > 0 ? buildAbsorverAndLoading() : buildDataTable()),
    );
  }
}
