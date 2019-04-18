import 'package:flutter/material.dart';
import 'Track.dart';
import 'Session.dart';
import 'package:asciiwwdc/SessionDetailPage.dart';

class ConferenceDetailPage extends StatefulWidget {
  final List<Track> tracks;

  ConferenceDetailPage({Key key, @required this.tracks}):super(key:key);

  @override
  _ConferenceDetailState createState() => new _ConferenceDetailState();
}

class _ConferenceDetailState extends State<ConferenceDetailPage>{


  Widget _buildRow(Session session, int row, int column) {


    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6.0,horizontal: 12.0),
                child: Text(
                  session.sessionTitle,
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
                session.toggleFavorite();
                setState(() {
                  widget.tracks[row].sessions[column] = session;
                });
              },
              iconSize: 20,
            ),
          ],
        ),
      ),
      onTap: () async {
        Navigator.push(context, new MaterialPageRoute(builder: (context) => new SessionDetailPage(session: session,)),);
      },
    );
  }


  List<Widget> _buildExpansionTileChildren(Track track, int row) {
    List<Widget> tiles = [];

    for(int col = 0; col < track.sessions.length;col++) {
      tiles.add(_buildRow(track.sessions[col], row, col));
    }

    return tiles;
  }

  Widget _buildExpansionTile(Track track, int row) {

    return new ExpansionTile(
      title: new Text(track.trackName),
      key: new PageStorageKey(track),
      children: _buildExpansionTileChildren(track, row),
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
          itemBuilder: (BuildContext context, int row) => _buildExpansionTile(widget.tracks[row],row),
          itemCount: widget.tracks.length,
        ),
      ),
    );
  }
}