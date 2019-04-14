import 'package:flutter/material.dart';
import 'package:material_search/material_search.dart';
import 'Conference.dart';
import 'Session.dart';
import 'Track.dart';

class TracksSearchPage extends StatefulWidget {

  final List<Conference> conferences;

  TracksSearchPage({Key key, @required this.conferences}):super(key: key);

  @override
  _TracksSearchState createState() => new _TracksSearchState();
}

class _TracksSearchState extends State<TracksSearchPage> {

  List<String> _sessionTitles = [];

  @override
  void initState() {

    super.initState();

    for(int i = 0; i < widget.conferences.length;i++) {
      Conference conference = widget.conferences[i];

      for(int j = 0; j < conference.tracks.length;j++) {
        Track track = conference.tracks[j];

        for(int k = 0; k < track.sessions.length;k++) {
          Session session = track.sessions[k];

          _sessionTitles.add(session.sessionTitle);
        }
      }
    }

  }


  List<String> _fetchList(String queryString){
    
    return _sessionTitles.where((title) => title.contains(queryString));
  }
  
  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      body: new MaterialSearch(
        placeholder: 'Search',
        getResults: (String queryString) async {
          List<String> _list = _fetchList(queryString);
          return _list.map((trackName) => new MaterialSearchResult<String>(
            value:trackName,
            text: trackName,
          )).toList();
        },
        onSelect: (String selected) {

        },
        onSubmit: (String toSubmit) {

        },
      ),
    );
  }

}