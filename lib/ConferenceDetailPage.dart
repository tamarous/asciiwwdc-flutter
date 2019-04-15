import 'package:flutter/material.dart';
import 'Track.dart';
import 'Session.dart';
import 'package:asciiwwdc/TrackDetailPage.dart';

class ConferenceDetailPage extends StatefulWidget {
  final List<Track> tracks;

  ConferenceDetailPage({Key key, @required this.tracks}):super(key:key);

  @override
  _ConferenceDetailState createState() => new _ConferenceDetailState();
}

class _ConferenceDetailState extends State<ConferenceDetailPage>{

  Widget _buildRow(Session session) {
    return new GestureDetector(
      child:new ListTile(
        title: new Text(
          session.sessionTitle,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(context, new MaterialPageRoute(builder: (context) => new SessionDetailPage(session: session,)),);
      },
    );
  }

  Widget _buildExpansionTile(Track track) {

    return new ExpansionTile(
      title: new Text(track.trackName),
      key: new PageStorageKey(track),
      children: track.sessions.map(_buildRow).toList(),
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
          itemBuilder: (BuildContext context, int index) => _buildExpansionTile(widget.tracks[index]),
          itemCount: widget.tracks.length,
        ),
      ),
    );
  }
}