import 'package:flutter/material.dart';
import 'package:material_search/material_search.dart';
import 'Conference.dart';


class TracksSearchPage extends StatefulWidget {

  List<Conference> conferences;

  TracksSearchPage({Key key, @required this.conferences}):super(key: key);

  @override
  _TracksSearchState createState() => new _TracksSearchState();
}

class _TracksSearchState extends State<TracksSearchPage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }

}