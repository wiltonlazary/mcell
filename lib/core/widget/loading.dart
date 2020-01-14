import 'package:flutter/material.dart';

import '../index.dart';
import '../theme.dart';

class Loading extends StatelessWidget {
  const Loading({Key key, this.width = 60.0, this.height = 60.0}) : super(key: key);

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    LoadingTheme loadingTheme = LoadingTheme.instance;

    try {
      loadingTheme = CoreTheme.of(context).loadingTheme;
    } catch (e) {
      //Silent
    }

    return Center(
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(4),
        child: CircularProgressIndicator(
          strokeWidth: loadingTheme.stroke,
          valueColor: AlwaysStoppedAnimation(loadingTheme.color), //OBS: some times freeze entire app on web ;(
          //backgroundColor: loadingTheme.backgroundColor,
        ),
      ),
    );
  }
}

@immutable
class LoadingFuture extends StatelessWidget {
  LoadingFuture({this.future, this.builder});

  final Future<dynamic> future;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        return snapshot.connectionState != ConnectionState.done ? Loading() : builder(context);
      },
    );
  }
}
