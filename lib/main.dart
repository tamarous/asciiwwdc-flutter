import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

import './Views/AllConferencesPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: new AllConferencesPage(),
    );
  }

  @override
  void initState() {
    super.initState();

    final QuickActions quickActions = const QuickActions();

    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'action_main') {
        print('The user tapped the main view');
      } else if (shortcutType == 'action_favorite') {
        print('The user tappped the favorite view');
      }

    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type:'action_main',
        localizedTitle: 'Main view',
      ),
      const ShortcutItem(
        type: 'action_favorite',
        localizedTitle: 'Favorite view',
      ),
    ]);
  }
}


