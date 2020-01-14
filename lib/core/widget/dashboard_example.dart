import 'package:flutter/material.dart';

import 'card.dart';

class ListContainer extends StatefulWidget {
  final Widget child;
  ListContainer({this.child});

  @override
  _ListContainerState createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final loading = false;

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              margin: EdgeInsets.only(top: 12),
              child: Column(
                children: <Widget>[
                  MediaQuery.of(context).size.width < 1300
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List<Widget>.generate(4, (i) {
                            return tickets(Colors.red, context, Icons.access_alarm, "111", "222");
                          }),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List<Widget>.generate(4, (i) {
                            return tickets(Colors.red, context, Icons.access_alarm, "111", "222");
                          })),
                  SizedBox(
                    height: 16,
                  ),
                  loading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : tableCard(context, [
                          {""}
                        ]),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

Widget tickets(Color color, BuildContext context, IconData icon, String ticketsNumber, String newCount) {
  return Card(
    elevation: 2,
    child: Container(
      padding: EdgeInsets.all(22),
      color: color,
      width: MediaQuery.of(context).size.width < 1300 ? MediaQuery.of(context).size.width - 100 : MediaQuery.of(context).size.width / 5.5,
      height: MediaQuery.of(context).size.height / 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                icon,
                size: 36,
                color: Colors.white,
              ),
              Text(
                "View Details",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                  fontFamily: 'HelveticaNeue',
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                ticketsNumber,
                style: TextStyle(
                  fontSize: 34,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                newCount,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                  fontFamily: 'HelveticaNeue',
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}

Widget tableCard(BuildContext context, List<dynamic> data) {
  return Card(
    elevation: 2.0,
    child: Column(children: [
      Container(
        width: MediaQuery.of(context).size.width < 1300 ? MediaQuery.of(context).size.width - 100 : MediaQuery.of(context).size.width - 330,
        padding: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
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
                  padding: EdgeInsets.all(18),
                  child: Text(
                    "No.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaNeue',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    "Author Name",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaNeue',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    "Language",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaNeue',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    "Stars",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'HelveticaNeue',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width < 1300 ? MediaQuery.of(context).size.width - 100 : MediaQuery.of(context).size.width - 330,
        // padding: EdgeInsets.all(32),
        child: Table(
          columnWidths: <int, TableColumnWidth>{
            0: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
            1: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
            2: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
            3: FixedColumnWidth((MediaQuery.of(context).size.width / 5)),
          },
          children: List<TableRow>.generate(
            10,
            (i) {
              return TableRow(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey))),
                children: [
                  Container(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      (i + 1).toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'Raleway',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      "xxxx 1",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'HelveticaNeue',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      "xxxx 2",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'Raleway',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      "xxxx 3",
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
          ),
        ),
      ),
    ]),
  );
}
