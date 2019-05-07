import 'package:flutter/material.dart';
import 'package:material_search/material_search.dart';

import '../Model/Conference.dart';
import '../Model/Session.dart';
import '../Model/Track.dart';
import 'SessionDetailPage.dart';

class SearchPage extends StatefulWidget {

  final List<Conference> conferences;

  SearchPage({Key key, @required this.conferences}):super(key: key);

  @override
  _SearchState createState() => new _SearchState();
}

class _SearchState extends State<SearchPage> {

  List<Session> _sessions;

  @override
  void initState() {

    super.initState();

    List<Session> sessions = [];

    if (widget.conferences == null) {
      sessions = [];
    } else {
      for(int i = 0; i < widget.conferences.length;i++) {
          Conference conference = widget.conferences[i];

          for(int j = 0; j < conference.tracks.length;j++) {
            Track track = conference.tracks[j];
            for(int k = 0; k < track.sessions.length;k++) {
              sessions.add(track.sessions[k]);
            }
          }
      } 
    }
    setState(() {
      _sessions = sessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return new Scaffold(
      body: MaterialSearch(
        limit: 30,
        placeholder: 'Search',
        results: _sessions.map((Session session) => new MaterialSearchResult<Session>(
          value: session,
          text: session.sessionTitle,
        )).toList(),
        filter: (dynamic value, String query) {
          return (value as Session).sessionTitle.toLowerCase().trim().contains(query.toLowerCase().trim());
        },
        onSelect: (dynamic value) {
          Navigator.push(context, new MaterialPageRoute(
              builder: (context) => new SessionDetailPage(session: value as Session),
          ));
        },
        onSubmit: (String submitted) {

        },
      ),
    );
  }
}