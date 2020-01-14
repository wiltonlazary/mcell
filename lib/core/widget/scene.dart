import 'package:flutter/material.dart';

import 'scene_shell.dart';
import 'view.dart';

abstract class SceneModel extends ViewModel {
  @override
  SceneState get state => super.state;
}

abstract class SceneState<T extends StatefulWidget, M extends SceneModel> extends ViewState<T, M> {
  SceneShellState sceneShellState;

  @override
  void initState() {
    sceneShellState = SceneShellState.of(context);
    sceneShellState.shared = this;
    super.initState();
  }

  scrollToTop() {
    sceneShellState.scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
