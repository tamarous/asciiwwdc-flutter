import 'package:redux/redux.dart';
import 'package:flutter/material.dart';

import 'theme_redux.dart';


class GlobalState {

  ThemeData themeData;

  GlobalState({this.themeData});
}

GlobalState appReducer(GlobalState state, action) {
  return GlobalState(
    themeData: ThemeDataReducer(state.themeData, action),
  );
}




