import 'package:flutter/material.dart';
import '../mcell.dart';
import '../theme.dart';
import '../widget/index.dart';
import '../remote.dart';

typedef Future<List<dynamic>> Fetcher({int offset, int limit});

class PaginatedTable extends StatefulWidget {
  final ModelCell cell;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Fetcher fetch;
  PaginatedTable({this.cell, this.margin, this.padding, this.fetch});

  @override
  _PaginatedTableState createState() => _PaginatedTableState();
}

class _PaginatedTableState extends State<PaginatedTable> {
  List<dynamic> rows;
  Future<dynamic> fetching;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  fetch() {
    fetching = widget.fetch().then((it) {
      rows = it;
    });
  }

  @override
  Widget build(BuildContext context) {
    return rows == null
        ? LoadingFuture(
            future: fetching,
            builder: (context) => _localTable(),
          )
        : _localTable();
  }

  Widget _localTable() {
    final theme = CoreTheme.of(context);
    final colorTheme = theme.colorTheme;

    final headerTextStyle = TextStyle(
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    );

    final headerPadding = EdgeInsets.fromLTRB(18, 6, 18, 6);
    final rowPadding = EdgeInsets.fromLTRB(18, 18, 18, 18);

    return CardContainer(
      margin: widget.margin,
      padding: EdgeInsets.fromLTRB(0, 6, 0, 6),
      elevation: 1,
      child: Column(children: [
        Container(
          width: double.infinity,
          child: Table(
            columnWidths: <int, TableColumnWidth>{
              0: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
              1: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
              2: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
              3: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(),
                children: [
                  Container(
                    padding: headerPadding,
                    child: Text(
                      "No.",
                      style: headerTextStyle,
                    ),
                  ),
                  Container(
                    padding: headerPadding,
                    child: Text(
                      "Author Name",
                      style: headerTextStyle,
                    ),
                  ),
                  Container(
                    padding: headerPadding,
                    child: Text(
                      "Language",
                      style: headerTextStyle,
                    ),
                  ),
                  Container(
                    padding: headerPadding,
                    child: Text(
                      "Stars",
                      style: headerTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          child: Table(
            columnWidths: <int, TableColumnWidth>{
              0: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
              1: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
              2: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
              3: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
            },
            children: rows.map(
              (row) {
                return TableRow(
                  decoration: BoxDecoration(border: Border(top: BorderSide(width: 0.5, color: Colors.grey))),
                  children: [
                    Container(
                      padding: rowPadding,
                      child: Text(
                        "000",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                    Container(
                      padding: rowPadding,
                      child: Text(
                        row["name"],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'HelveticaNeue',
                        ),
                      ),
                    ),
                    Container(
                      padding: rowPadding,
                      child: Text(
                        "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                    Container(
                      padding: rowPadding,
                      child: Text(
                        "*****",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'HelveticaNeue',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ]),
    );
  }
}
