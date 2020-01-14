// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef CoreDataColumnSortCallback = void Function(int columnIndex, bool ascending);

abstract class CoreDataTableSource extends ChangeNotifier {
  CoreDataRow getRow(int index);
  int get rowCount;
  bool get isRowCountApproximate;
  int get selectedRowCount;
}

@immutable
class CoreDataColumn {
  const CoreDataColumn({
    @required this.label,
    this.tooltip,
    this.numeric = false,
    this.onSort,
  }) : assert(label != null);

  final Widget label;
  final String tooltip;
  final bool numeric;
  final CoreDataColumnSortCallback onSort;

  bool get _debugInteractive => onSort != null;
}

@immutable
class CoreDataRow {
  const CoreDataRow({
    this.key,
    this.selected = false,
    this.onSelectChanged,
    @required this.cells,
  }) : assert(cells != null);

  CoreDataRow.byIndex({
    int index,
    this.selected = false,
    this.onSelectChanged,
    @required this.cells,
  })  : assert(cells != null),
        key = ValueKey<int>(index);

  final LocalKey key;
  final ValueChanged<bool> onSelectChanged;
  final bool selected;
  final List<CoreDataCell> cells;

  bool get _debugInteractive => onSelectChanged != null || cells.any((CoreDataCell cell) => cell._debugInteractive);
}

@immutable
class CoreDataCell {
  const CoreDataCell(
    this.child, {
    this.placeholder = false,
    this.showEditIcon = false,
    this.onTap,
  }) : assert(child != null);

  static final CoreDataCell empty = CoreDataCell(Container(width: 0.0, height: 0.0));
  final Widget child;
  final bool placeholder;
  final bool showEditIcon;
  final VoidCallback onTap;

  bool get _debugInteractive => onTap != null;
}

class CoreDataTable extends StatelessWidget {
  CoreDataTable({
    Key key,
    @required this.columns,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSelectAll,
    this.dataRowHeight = kMinInteractiveDimension,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    @required this.rows,
  })  : assert(columns != null),
        assert(columns.isNotEmpty),
        assert(sortColumnIndex == null || (sortColumnIndex >= 0 && sortColumnIndex < columns.length)),
        assert(sortAscending != null),
        assert(dataRowHeight != null),
        assert(headingRowHeight != null),
        assert(horizontalMargin != null),
        assert(columnSpacing != null),
        assert(rows != null),
        assert(!rows.any((CoreDataRow row) => row.cells.length != columns.length)),
        _onlyTextColumn = _initOnlyTextColumn(columns),
        super(key: key);

  final List<CoreDataColumn> columns;
  final int sortColumnIndex;
  final bool sortAscending;
  final ValueSetter<bool> onSelectAll;
  final double dataRowHeight;
  final double headingRowHeight;
  final double horizontalMargin;
  final double columnSpacing;
  final List<CoreDataRow> rows;

  final int _onlyTextColumn;
  static int _initOnlyTextColumn(List<CoreDataColumn> columns) {
    int result;

    for (int index = 0; index < columns.length; index += 1) {
      final CoreDataColumn column = columns[index];
      if (!column.numeric) {
        if (result != null) return null;
        result = index;
      }
    }

    return result;
  }

  bool get _debugInteractive {
    return columns.any((CoreDataColumn column) => column._debugInteractive) || rows.any((CoreDataRow row) => row._debugInteractive);
  }

  static final LocalKey _headingRowKey = UniqueKey();

  void _handleSelectAll(bool checked) {
    if (onSelectAll != null) {
      onSelectAll(checked);
    } else {
      for (CoreDataRow row in rows) {
        if ((row.onSelectChanged != null) && (row.selected != checked)) row.onSelectChanged(checked);
      }
    }
  }

  static const double _sortArrowPadding = 2.0;
  static const double _headingFontSize = 12.0;
  static const Duration _sortArrowAnimationDuration = Duration(milliseconds: 150);
  static const Color _grey100Opacity = Color(0x0A000000); // Grey 100 as opacity instead of solid color
  static const Color _grey300Opacity = Color(0x1E000000); // Dark theme variant is just a guess.

  Widget _buildCheckbox({
    Color color,
    bool checked,
    VoidCallback onRowTap,
    ValueChanged<bool> onCheckboxChanged,
  }) {
    Widget contents = Semantics(
      container: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: horizontalMargin, end: horizontalMargin / 2.0),
        child: Center(
          child: Checkbox(
            activeColor: color,
            value: checked,
            onChanged: onCheckboxChanged,
          ),
        ),
      ),
    );

    if (onRowTap != null) {
      contents = CoreTableRowInkWell(
        onTap: onRowTap,
        child: contents,
      );
    }

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: contents,
    );
  }

  Widget _buildHeadingCell({
    BuildContext context,
    EdgeInsetsGeometry padding,
    Widget label,
    String tooltip,
    bool numeric,
    VoidCallback onSort,
    bool sorted,
    bool ascending,
  }) {
    if (onSort != null) {
      final Widget arrow = _SortArrow(
        visible: sorted,
        down: sorted ? ascending : null,
        duration: _sortArrowAnimationDuration,
      );
      const Widget arrowPadding = SizedBox(width: _sortArrowPadding);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[label, arrowPadding, arrow],
      );
    }

    label = Container(
      padding: padding,
      height: headingRowHeight,
      alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: AnimatedDefaultTextStyle(
        style: TextStyle(
          // TODO(ianh): font family should match Theme; see https://github.com/flutter/flutter/issues/3116
          fontWeight: FontWeight.w500,
          fontSize: _headingFontSize,
          height: math.min(1.0, headingRowHeight / _headingFontSize),
          color: (Theme.of(context).brightness == Brightness.light)
              ? ((onSort != null && sorted) ? Colors.black87 : Colors.black54)
              : ((onSort != null && sorted) ? Colors.white : Colors.white70),
        ),
        softWrap: false,
        duration: _sortArrowAnimationDuration,
        child: label,
      ),
    );

    if (tooltip != null) {
      label = Tooltip(
        message: tooltip,
        child: label,
      );
    }

    if (onSort != null) {
      label = InkWell(
        onTap: onSort,
        child: label,
      );
    }

    return label;
  }

  Widget _buildDataCell({
    BuildContext context,
    EdgeInsetsGeometry padding,
    Widget label,
    bool numeric,
    bool placeholder,
    bool showEditIcon,
    VoidCallback onTap,
    VoidCallback onSelectChanged,
  }) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;

    if (showEditIcon) {
      const Widget icon = Icon(Icons.edit, size: 18.0);
      label = Expanded(child: label);
      label = Row(
        textDirection: numeric ? TextDirection.rtl : null,
        children: <Widget>[label, icon],
      );
    }

    label = Container(
      padding: padding,
      height: dataRowHeight,
      alignment: numeric ? Alignment.centerRight : AlignmentDirectional.centerStart,
      child: DefaultTextStyle(
        style: TextStyle(
          // TODO(ianh): font family should be Roboto; see https://github.com/flutter/flutter/issues/3116
          fontSize: 13.0,
          color: isLightTheme ? (placeholder ? Colors.black38 : Colors.black87) : (placeholder ? Colors.white38 : Colors.white70),
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: isLightTheme ? Colors.black54 : Colors.white70,
          ),
          child: DropdownButtonHideUnderline(child: label),
        ),
      ),
    );

    if (onTap != null) {
      label = InkWell(
        onTap: onTap,
        child: label,
      );
    } else if (onSelectChanged != null) {
      label = CoreTableRowInkWell(
        onTap: onSelectChanged,
        child: label,
      );
    }

    return label;
  }

  @override
  Widget build(BuildContext context) {
    assert(!_debugInteractive || debugCheckHasMaterial(context));
    final ThemeData theme = Theme.of(context);

    final BoxDecoration _kSelectedDecoration = BoxDecoration(
      border: Border(bottom: Divider.createBorderSide(context, width: 1.0)),
      // The backgroundColor has to be transparent so you can see the ink on the material
      color: (Theme.of(context).brightness == Brightness.light) ? _grey100Opacity : _grey300Opacity,
    );

    final BoxDecoration _kUnselectedDecoration = BoxDecoration(
      border: Border(bottom: Divider.createBorderSide(context, width: 1.0)),
    );

    final bool showCheckboxColumn = rows.any((CoreDataRow row) => row.onSelectChanged != null);
    final bool allChecked = showCheckboxColumn && !rows.any((CoreDataRow row) => row.onSelectChanged != null && !row.selected);
    final List<TableColumnWidth> tableColumns = List<TableColumnWidth>(columns.length + (showCheckboxColumn ? 1 : 0));

    final List<TableRow> tableRows = List<TableRow>.generate(
      rows.length + 1, // the +1 is for the header row
      (int index) {
        return TableRow(
          key: index == 0 ? _headingRowKey : rows[index - 1].key,
          decoration: index > 0 && rows[index - 1].selected ? _kSelectedDecoration : _kUnselectedDecoration,
          children: List<Widget>(tableColumns.length),
        );
      },
    );

    int rowIndex;
    int displayColumnIndex = 0;

    if (showCheckboxColumn) {
      tableColumns[0] = FixedColumnWidth(horizontalMargin + Checkbox.width + horizontalMargin / 2.0);
      tableRows[0].children[0] = _buildCheckbox(
        color: theme.accentColor,
        checked: allChecked,
        onCheckboxChanged: _handleSelectAll,
      );

      rowIndex = 1;

      for (CoreDataRow row in rows) {
        tableRows[rowIndex].children[0] = _buildCheckbox(
          color: theme.accentColor,
          checked: row.selected,
          onRowTap: () => row.onSelectChanged != null ? row.onSelectChanged(!row.selected) : null,
          onCheckboxChanged: row.onSelectChanged,
        );

        rowIndex += 1;
      }

      displayColumnIndex += 1;
    }

    for (int dataColumnIndex = 0; dataColumnIndex < columns.length; dataColumnIndex += 1) {
      final CoreDataColumn column = columns[dataColumnIndex];
      double paddingStart;

      if (dataColumnIndex == 0 && showCheckboxColumn) {
        paddingStart = horizontalMargin / 2.0;
      } else if (dataColumnIndex == 0 && !showCheckboxColumn) {
        paddingStart = horizontalMargin;
      } else {
        paddingStart = columnSpacing / 2.0;
      }

      double paddingEnd;

      if (dataColumnIndex == columns.length - 1) {
        paddingEnd = horizontalMargin;
      } else {
        paddingEnd = columnSpacing / 2.0;
      }

      final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
        start: paddingStart,
        end: paddingEnd,
      );

      if (dataColumnIndex == _onlyTextColumn) {
        tableColumns[displayColumnIndex] = const IntrinsicColumnWidth(flex: 1.0);
      } else {
        tableColumns[displayColumnIndex] = const IntrinsicColumnWidth();
      }

      tableRows[0].children[displayColumnIndex] = _buildHeadingCell(
        context: context,
        padding: padding,
        label: column.label,
        tooltip: column.tooltip,
        numeric: column.numeric,
        onSort: () => column.onSort != null ? column.onSort(dataColumnIndex, sortColumnIndex != dataColumnIndex || !sortAscending) : null,
        sorted: dataColumnIndex == sortColumnIndex,
        ascending: sortAscending,
      );

      rowIndex = 1;

      for (CoreDataRow row in rows) {
        final CoreDataCell cell = row.cells[dataColumnIndex];

        tableRows[rowIndex].children[displayColumnIndex] = _buildDataCell(
          context: context,
          padding: padding,
          label: cell.child,
          numeric: column.numeric,
          placeholder: cell.placeholder,
          showEditIcon: cell.showEditIcon,
          onTap: cell.onTap,
          onSelectChanged: () => row.onSelectChanged != null ? row.onSelectChanged(!row.selected) : null,
        );

        rowIndex += 1;
      }

      displayColumnIndex += 1;
    }

    return Table(
      columnWidths: tableColumns.asMap(),
      children: tableRows,
    );
  }
}

class CoreTableRowInkWell extends InkResponse {
  const CoreTableRowInkWell({
    Key key,
    Widget child,
    GestureTapCallback onTap,
    GestureTapCallback onDoubleTap,
    GestureLongPressCallback onLongPress,
    ValueChanged<bool> onHighlightChanged,
  }) : super(
          key: key,
          child: child,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          onHighlightChanged: onHighlightChanged,
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
        );

  @override
  RectCallback getRectCallback(RenderBox referenceBox) {
    return () {
      RenderObject cell = referenceBox;
      AbstractNode table = cell.parent;
      final Matrix4 transform = Matrix4.identity();

      while (table is RenderObject && table is! RenderTable) {
        final RenderTable parentBox = table;
        parentBox.applyPaintTransform(cell, transform);
        assert(table == cell.parent);
        cell = table;
        table = table.parent;
      }

      if (table is RenderTable) {
        final TableCellParentData cellParentData = cell.parentData;
        assert(cellParentData.y != null);
        final Rect rect = table.getRowBox(cellParentData.y);
        // The rect is in the table's coordinate space. We need to change it to the
        // TableRowInkWell's coordinate space.
        table.applyPaintTransform(cell, transform);
        final Offset offset = MatrixUtils.getAsTranslation(transform);
        if (offset != null) return rect.shift(-offset);
      }

      return Rect.zero;
    };
  }

  @override
  bool debugCheckContext(BuildContext context) {
    assert(debugCheckHasTable(context));
    return super.debugCheckContext(context);
  }
}

class _SortArrow extends StatefulWidget {
  const _SortArrow({
    Key key,
    this.visible,
    this.down,
    this.duration,
  }) : super(key: key);

  final bool visible;
  final bool down;
  final Duration duration;

  @override
  _SortArrowState createState() => _SortArrowState();
}

class _SortArrowState extends State<_SortArrow> with TickerProviderStateMixin {
  AnimationController _opacityController;
  Animation<double> _opacityAnimation;
  AnimationController _orientationController;
  Animation<double> _orientationAnimation;
  double _orientationOffset = 0.0;
  bool _down;

  static final Animatable<double> _turnTween = Tween<double>(begin: 0.0, end: math.pi).chain(CurveTween(curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    _opacityAnimation = CurvedAnimation(
      parent: _opacityController = AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
      curve: Curves.fastOutSlowIn,
    )..addListener(_rebuild);
    _opacityController.value = widget.visible ? 1.0 : 0.0;
    _orientationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _orientationAnimation = _orientationController.drive(_turnTween)
      ..addListener(_rebuild)
      ..addStatusListener(_resetOrientationAnimation);
    if (widget.visible) _orientationOffset = widget.down ? 0.0 : math.pi;
  }

  void _rebuild() {
    setState(() {
      // The animations changed, so we need to rebuild.
    });
  }

  void _resetOrientationAnimation(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      assert(_orientationAnimation.value == math.pi);
      _orientationOffset += math.pi;
      _orientationController.value = 0.0; // TODO(ianh): This triggers a pointless rebuild.
    }
  }

  @override
  void didUpdateWidget(_SortArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool skipArrow = false;
    final bool newDown = widget.down ?? _down;

    if (oldWidget.visible != widget.visible) {
      if (widget.visible && (_opacityController.status == AnimationStatus.dismissed)) {
        _orientationController.stop();
        _orientationController.value = 0.0;
        _orientationOffset = newDown ? 0.0 : math.pi;
        skipArrow = true;
      }

      if (widget.visible) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }

    if ((_down != newDown) && !skipArrow) {
      if (_orientationController.status == AnimationStatus.dismissed) {
        _orientationController.forward();
      } else {
        _orientationController.reverse();
      }
    }

    _down = newDown;
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _orientationController.dispose();
    super.dispose();
  }

  static const double _arrowIconBaselineOffset = -1.5;
  static const double _arrowIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Transform(
        transform: Matrix4.rotationZ(_orientationOffset + _orientationAnimation.value)
          ..setTranslationRaw(0.0, _arrowIconBaselineOffset, 0.0),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_downward,
          size: _arrowIconSize,
          color: (Theme.of(context).brightness == Brightness.light) ? Colors.black87 : Colors.white70,
        ),
      ),
    );
  }
}
