import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';


final ThemeDataReducer = combineReducers<ThemeData>([
  TypedReducer<ThemeData, RefreshThemeDataAction>(_refresh),
]);

ThemeData _refresh(ThemeData themeData, action) {
  themeData = action.themeData;
  return themeData;
}


class RefreshThemeDataAction {
  final ThemeData themeData;
  RefreshThemeDataAction(this.themeData);
}
