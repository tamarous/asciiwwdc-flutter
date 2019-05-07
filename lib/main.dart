import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import './Views/all_conferences_page.dart';
import './Redux/global_state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final store = Store<GlobalState>(
    appReducer,
    initialState:GlobalState(
      themeData: ThemeData(
        primaryColor: Colors.white,
      ),
    )
  );



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return StoreProvider(
      store: store,
      child: StoreBuilder<GlobalState>(builder: (context, store) {
        return MaterialApp(
          theme:store.state.themeData,
          home: MyHomePage(),
        );
      })
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
}


