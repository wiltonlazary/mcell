// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;

import 'card.dart';
import 'core_data_table.dart';

class RichDataTable extends StatefulWidget {
  RichDataTable({
    Key key,
    this.actions,
    @required this.columns,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSelectAll,
    this.dataRowHeight = kMinInteractiveDimension,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    this.initialFirstRowIndex = 0,
    this.onPageChanged,
    this.rowsPerPage = defaultRowsPerPage,
    this.availableRowsPerPage = const <int>[defaultRowsPerPage, defaultRowsPerPage * 2, defaultRowsPerPage * 5, defaultRowsPerPage * 10],
    this.onRowsPerPageChanged,
    this.dragStartBehavior = DragStartBehavior.start,
    @required this.source,
  })  : assert(columns != null),
        assert(dragStartBehavior != null),
        assert(columns.isNotEmpty),
        assert(sortColumnIndex == null || (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
        assert(sortAscending != null),
        assert(dataRowHeight != null),
        assert(headingRowHeight != null),
        assert(horizontalMargin != null),
        assert(columnSpacing != null),
        assert(rowsPerPage != null),
        assert(rowsPerPage > 0),
        assert(() {
          if (onRowsPerPageChanged != null) assert(availableRowsPerPage != null && availableRowsPerPage.contains(rowsPerPage));
          return true;
        }()),
        assert(source != null),
        super(key: key);

  final List<Widget> actions;
  final List<CoreDataColumn> columns;
  final int sortColumnIndex;
  final bool sortAscending;
  final ValueSetter<bool> onSelectAll;
  final double dataRowHeight;
  final double headingRowHeight;
  final double horizontalMargin;
  final double columnSpacing;
  final int initialFirstRowIndex;
  final ValueChanged<int> onPageChanged;
  final int rowsPerPage;
  static const int defaultRowsPerPage = 10;
  final List<int> availableRowsPerPage;
  final ValueChanged<int> onRowsPerPageChanged;
  final CoreDataTableSource source;
  final DragStartBehavior dragStartBehavior;

  @override
  RichDataTableState createState() => RichDataTableState();
}

/// Holds the state of a [RichDataTable].
///
/// The table can be programmatically paged using the [pageTo] method.
class RichDataTableState extends State<RichDataTable> {
  int _firstRowIndex;
  int _rowCount;
  bool _rowCountApproximate;
  int _selectedRowCount;
  final Map<int, CoreDataRow> _rows = <int, CoreDataRow>{};

  @override
  void initState() {
    super.initState();
    _firstRowIndex = PageStorage.of(context)?.readState(context) ?? widget.initialFirstRowIndex ?? 0;
    widget.source.addListener(_handleDataSourceChanged);
    _handleDataSourceChanged();
  }

  @override
  void didUpdateWidget(RichDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      oldWidget.source.removeListener(_handleDataSourceChanged);
      widget.source.addListener(_handleDataSourceChanged);
      _handleDataSourceChanged();
    }
  }

  @override
  void dispose() {
    widget.source.removeListener(_handleDataSourceChanged);
    super.dispose();
  }

  void _handleDataSourceChanged() {
    setState(() {
      _rowCount = widget.source.rowCount;
      _rowCountApproximate = widget.source.isRowCountApproximate;
      _selectedRowCount = widget.source.selectedRowCount;
      _rows.clear();
    });
  }

  /// Ensures that the given row is visible.
  void pageTo(int rowIndex) {
    final int oldFirstRowIndex = _firstRowIndex;

    setState(() {
      final int rowsPerPage = widget.rowsPerPage;
      _firstRowIndex = (rowIndex ~/ rowsPerPage) * rowsPerPage;
    });

    if ((widget.onPageChanged != null) && (oldFirstRowIndex != _firstRowIndex)) widget.onPageChanged(_firstRowIndex);
  }

  CoreDataRow _getBlankRowFor(int index) {
    return CoreDataRow.byIndex(
      index: index,
      cells: widget.columns.map<CoreDataCell>((CoreDataColumn column) => CoreDataCell.empty).toList(),
    );
  }

  CoreDataRow _getProgressIndicatorRowFor(int index) {
    bool haveProgressIndicator = false;

    final List<CoreDataCell> cells = widget.columns.map<CoreDataCell>((CoreDataColumn column) {
      if (!column.numeric) {
        haveProgressIndicator = true;
        return const CoreDataCell(CircularProgressIndicator());
      }

      return CoreDataCell.empty;
    }).toList();

    if (!haveProgressIndicator) {
      haveProgressIndicator = true;
      cells[0] = const CoreDataCell(CircularProgressIndicator());
    }

    return CoreDataRow.byIndex(
      index: index,
      cells: cells,
    );
  }

  List<CoreDataRow> _getRows(int firstRowIndex, int rowsPerPage) {
    final List<CoreDataRow> result = <CoreDataRow>[];
    final int nextPageFirstRowIndex = firstRowIndex + rowsPerPage;
    bool haveProgressIndicator = false;

    for (int index = firstRowIndex; index < nextPageFirstRowIndex; index += 1) {
      CoreDataRow row;

      if (index < _rowCount || _rowCountApproximate) {
        row = _rows.putIfAbsent(index, () => widget.source.getRow(index));

        if (row == null && !haveProgressIndicator) {
          row ??= _getProgressIndicatorRowFor(index);
          haveProgressIndicator = true;
        }
      }

      row ??= _getBlankRowFor(index);
      result.add(row);
    }

    return result;
  }

  void _handlePrevious() {
    pageTo(math.max(_firstRowIndex - widget.rowsPerPage, 0));
  }

  void _handleNext() {
    pageTo(_firstRowIndex + widget.rowsPerPage);
  }

  final GlobalKey _tableKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    //final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    buildIconButton({IconData iconData, EdgeInsetsGeometry padding, VoidCallback onPressed}) {
      return onPressed == null
          ? Container(
              padding: padding,
              width: 48,
              child: Icon(
                iconData,
                color: themeData.disabledColor,
              ),
            )
          : IconButton(
              icon: Icon(iconData),
              padding: padding,
              onPressed: onPressed,
            );
    }

    final TextStyle footerTextStyle = themeData.textTheme.caption;
    final List<Widget> footerWidgets = <Widget>[];

    if (widget.onRowsPerPageChanged != null) {
      final List<Widget> availableRowsPerPage = widget.availableRowsPerPage
          .where((int value) => value <= _rowCount || value == widget.rowsPerPage)
          .map<DropdownMenuItem<int>>(
            (int value) => DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            ),
          )
          .toList();

      footerWidgets.addAll(<Widget>[
        Container(width: 14.0), // to match trailing padding in case we overflow and end up scrolling
        Text("Linhas por pagina"),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64.0), // 40.0 for the text, 24.0 for the icon
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                items: availableRowsPerPage,
                value: widget.rowsPerPage,
                onChanged: widget.onRowsPerPageChanged,
                style: footerTextStyle,
                iconSize: 24.0,
              ),
            ),
          ),
        ),
      ]);
    }

    footerWidgets.addAll(<Widget>[
      Container(width: 32.0),
      Text("${_firstRowIndex + 1}-${_firstRowIndex + widget.rowsPerPage} de ${_rowCount}"),
      SizedBox(width: 32.0),
      buildIconButton(
        iconData: Icons.chevron_left,
        padding: EdgeInsets.zero,
        onPressed: _firstRowIndex <= 0 ? null : _handlePrevious,
      ),
      SizedBox(width: 24.0),
      buildIconButton(
        iconData: Icons.chevron_right,
        padding: EdgeInsets.zero,
        onPressed: (!_rowCountApproximate && (_firstRowIndex + widget.rowsPerPage >= _rowCount)) ? null : _handleNext,
      ),
      SizedBox(width: 14.0),
    ]);

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            dragStartBehavior: widget.dragStartBehavior,
            child: CoreDataTable(
              key: _tableKey,
              columns: widget.columns,
              sortColumnIndex: widget.sortColumnIndex,
              sortAscending: widget.sortAscending,
              onSelectAll: widget.onSelectAll,
              dataRowHeight: widget.dataRowHeight,
              headingRowHeight: widget.headingRowHeight,
              horizontalMargin: widget.horizontalMargin,
              columnSpacing: widget.columnSpacing,
              rows: _getRows(_firstRowIndex, widget.rowsPerPage),
            ),
          ),
          DefaultTextStyle(
            style: footerTextStyle,
            child: IconTheme.merge(
              data: const IconThemeData(opacity: 0.54),
              child: Container(
                height: 56.0,
                child: SingleChildScrollView(
                  dragStartBehavior: widget.dragStartBehavior,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: footerWidgets,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
