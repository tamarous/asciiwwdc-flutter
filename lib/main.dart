import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AllConferencesPage.dart';
import 'FavoriteTracksPage.dart';

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
//      bottomNavigationBar: BottomNavigationBar(
//        items: [
//          BottomNavigationBarItem(
//            icon: Icon(
//              Icons.list,
//              color: _bottomNavigationColor,
//            ),
//            title: Text(
//              'All',
//              style:TextStyle(
//                color:Colors.black
//              )
//            ),
//          ),
//          BottomNavigationBarItem(
//            icon:Icon(
//                Icons.favorite,
//                color: _bottomNavigationColor,
//            ),
//            title: Text(
//              'Favorites',
//              style:TextStyle(
//                color:Colors.black,
//              )
//            )
//          )
//        ],
//        currentIndex: _selectedIndex,
//        onTap: (int index) {
//          setState(() {
//            _selectedIndex = index;
//            print('_selectedIndex changed to ${_selectedIndex}');
//          });
//        },
//      ),
      body: new AllConferencesPage(),
    );
  }
}


