import 'package:flutter/material.dart';

import '../Model/Track.dart';
import 'SessionDetailPage.dart';

class ConferenceDetailPage extends StatefulWidget {
  final List<Track> tracks;

  ConferenceDetailPage({Key key, @required this.tracks}):super(key:key);

  @override
  _ConferenceDetailState createState() => new _ConferenceDetailState();
}

class _ConferenceDetailState extends State<ConferenceDetailPage>{


  Widget _buildRow(int row, int column) {

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6.0,horizontal: 12.0),
                child: Text(
                  widget.tracks[row].sessions[column].sessionTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: widget.tracks[row].sessions[column].isFavorite?Icon(Icons.favorite):Icon(Icons.favorite_border),
              onPressed: () {
                widget.tracks[row].sessions[column].toggleFavorite();
                setState(() {
                  widget.tracks[row].sessions[column] = widget.tracks[row].sessions[column];
                });
              },
              iconSize: 20,
            ),
          ],
        ),
      ),
      onTap: () async {
        Navigator.push(context, new MaterialPageRoute(builder: (context) => new SessionDetailPage(session: widget.tracks[row].sessions[column],)),);
      },
    );
  }


  List<Widget> _buildExpansionTileChildren(int row) {
    List<Widget> tiles = [];

    for(int col = 0; col < widget.tracks[row].sessions.length;col++) {
      tiles.add(_buildRow(row, col));
    }

    return tiles;
  }

  Widget _buildExpansionTile(int row) {

    return new ExpansionTile(
      title: new Text(
        widget.tracks[row].trackName,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 20.0,
        ),
        ),
      key: new PageStorageKey(widget.tracks[row]),
      children: _buildExpansionTileChildren(row),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(

      appBar: AppBar(
        title: Text('Sessions'),
      ),

      body: new SafeArea(
        child: new ListView.builder(
          itemBuilder: (BuildContext context, int row) => _buildExpansionTile(row),
          itemCount: widget.tracks.length,
        ),
      ),
    );
  }
}