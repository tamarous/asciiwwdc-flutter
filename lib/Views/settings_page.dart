import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../Redux/theme_redux.dart';
import '../Redux/global_state.dart';


class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();
}


class SettingsPageState extends State<SettingsPage> {

  Store<GlobalState> _store;
  Color _selectedColor;

  final List<Color> _themeColors = [
    Colors.white,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.pink,
    Colors.purple,
  ];


  final Map<Color, String> _mappedColors = {
    Colors.white: 'White',
    Colors.blue: 'Blue',
    Colors.green: 'Green',
    Colors.yellow: 'Yellow',
    Colors.red: 'Red',
    Colors.pink:'Pink',
    Colors.purple: 'Purple',
  };

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    _store = StoreProvider.of(context);
    _selectedColor = _store.state.themeData.primaryColor;


    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: _buildDropdownButton(),
      ),
    );
  }

  Widget _buildDropdownButton() {
    Widget widget = Form(
      autovalidate: true,
      child: FormField(
          builder: (FormFieldState state) {
            return InputDecorator(
              decoration: InputDecoration(
                icon: Icon(Icons.color_lens),
                labelText: 'Color Theme',
              ),
              isEmpty: false,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                      isDense: true,
                      items: _themeColors.map((Color color) {
                        return DropdownMenuItem(
                          child: Text(_mappedColors[color]),
                          value: color,
                        );
                      }).toList(),
                      onChanged: (Color newColor) {
                        ThemeData themeData = ThemeData(primaryColor: newColor);
                        _store.dispatch(RefreshThemeDataAction(themeData));
                      }
                  )
              ),
            );
          }
      )
    );
    return widget;
  }
}