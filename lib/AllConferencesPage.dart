import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'Conference.dart';
import 'Session.dart';
import 'Track.dart';
import 'TracksSearchPage.dart';
import 'TracksSelectionPage.dart';

import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class AllConferencesPage extends StatefulWidget {

  @override
  AllConferencesState createState() => new AllConferencesState();
}

class AllConferencesState extends State<AllConferencesPage> {
  List<Conference> _conferences;

  bool hasData = false;

  final String URL_PREFIX = 'https://www.asciiwwdc.com';

  List<Session> parseSessions(List<dom.Element> sessionElements) {
    List<Session> sessions = new List<Session>();

    for(int i = 0; i < sessionElements.length;i++) {
      dom.Element sessionElement = sessionElements[i];

      var aElements = sessionElement.getElementsByTagName('a');

      for(int j = 0; j < aElements.length;j++) {

        dom.Element aElement = aElements[j];
        Session session = new Session();
        session.sessionUrlString = URL_PREFIX + aElement.attributes['href'];
        session.sessionTitle = aElement.attributes['title'];

        sessions.add(session);
      }
    }

    return sessions;
  }

  List<Track> parseTracks(List<dom.Element> trackElements) {
    List<Track> tracks = new List<Track>();

    for(int i = 0; i < trackElements.length;i++) {
      dom.Element trackElement = trackElements[i];

      var trackName = trackElement.getElementsByTagName('h1').first.text;

      List<Session> sessions = parseSessions(trackElement.getElementsByClassName('sessions'));

      Track track = new Track();
      track.trackName = trackName;
      track.sessions = sessions;

      tracks.add(track);
    }
    return tracks;
  }


  List<Conference> parseConferencesFromResponse(Response response) {

    List<Conference> conferences = new List();

    var document = parser.parse(response.data);

    var conferenceElements = document.getElementsByClassName('conference');

    for(int i = 0; i < conferenceElements.length;i++) {

      dom.Element conferenceElement = conferenceElements[i];
      var trackElements = conferenceElement.getElementsByClassName('track');
      List<Track> tracks = parseTracks(trackElements);

      var conferenceName = conferenceElement.getElementsByTagName('h1').first.text;
      var conferenceLogoUrl = conferenceElement.getElementsByTagName('img').first.attributes['src'];
      var conferenceShortDescription = conferenceElement.getElementsByTagName('h2').first.text;
      var conferenceTime = conferenceElement.getElementsByTagName('time').first.attributes['content'];

      Conference conference = new Conference();
      conference.conferenceName = conferenceName;
      conference.conferenceLogoUrl = URL_PREFIX + conferenceLogoUrl;
      conference.conferenceShortDescription = conferenceShortDescription;
      conference.tracks = tracks;
      conference.conferenceTime = conferenceTime;

      conferences.add(conference);
    }

    return conferences;
  }

  void getConferences() async {
    try {
      Response response = await Dio().get(URL_PREFIX);
      List<Conference> conferences = parseConferencesFromResponse(response);

      setState(() {
        _conferences = conferences;
        hasData = true;
      });

    } catch(e) {
      print(e);
    }
  }


  Widget _buildRow(Conference conference) {

    Widget textSection = new GestureDetector(
      child: new Container(
        margin: EdgeInsets.all(8.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Container(
                margin: EdgeInsets.only(left: 8.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      conference.conferenceName,
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    new Text(
                      conference.conferenceShortDescription,
                      style: new TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    new Text(
                      conference.conferenceTime,
                      style: new TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.push(context, new MaterialPageRoute(
            builder: (context) => new TracksSelectionPage(tracks: conference.tracks,)
        ),);
      },
    );
    return textSection;
  }

  Widget _buildConferences() {
    return new ListView.separated(
      separatorBuilder: (BuildContext context, int index) => new Divider(),
      itemCount: _conferences.length,
      itemBuilder: (context, i) {
        return _buildRow(_conferences[i]);
      },
      padding: const EdgeInsets.all(16.0),
    );
  }

  Widget _buildBlank() {
    return new Center(
      child: new Text('Hello World'),
    );
  }

  @override
  void initState() {
    super.initState();

    getConferences();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        title: new Text('ASCIIWWDC-Flutter'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.search), onPressed: () {
            Navigator.push(context, new MaterialPageRoute(builder: (context) => new TracksSearchPage(conferences: hasData?_conferences:new List<String>())));
          }),
        ],
      ),
      body: new SafeArea(child: hasData? _buildConferences():_buildBlank()),
    );
  }
}