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
      title: 'ASCIIWWDC',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: MyHomePage(title: 'ASCIIWWDC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  List<Widget> _pages = new List<Widget>();
  
  @override
  void initState() {
    super.initState();

    _pages.add(new AllConferencesPage());
    _pages.add(new FavoriteTracksPage());
  }

  @override
  Widget build(BuildContext context) {

    final _bottomNavigationColor = Colors.blue;
    int _selectedIndex = 0;

    void _onTapItem(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              color: _bottomNavigationColor,
            ),
            title: Text(
              'All',
              style:TextStyle(
                color:Colors.black
              )
            ),
          ),
          BottomNavigationBarItem(
            icon:Icon(
                Icons.favorite,
                color: _bottomNavigationColor,
            ),
            title: Text(
              'Favorites',
              style:TextStyle(
                color:Colors.black,
              )
            )   
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onTapItem
      ),
      body: _pages[_selectedIndex],
    );
  }
}


