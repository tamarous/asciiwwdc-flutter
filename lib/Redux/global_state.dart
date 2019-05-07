import 'package:flutter/material.dart';

import 'theme_redux.dart';


class GlobalState {

  ThemeData themeData;

  GlobalState({this.themeData});
}

GlobalState appReducer(GlobalState state, action) {
  return GlobalState(
    themeData: themeDataReducer(state.themeData, action),
  );
}




