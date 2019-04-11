import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'Conference.dart';
import 'Track.dart';
import 'Session.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'ASCIIWWDC',
      theme: new CupertinoThemeData(
        primaryColor: Colors.blue,
      ),
      home: MyHomePage(title: 'ASCIIWWDC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}




class _MyHomePageState extends State<MyHomePage> {

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
        session.urlString = URL_PREFIX + aElement.attributes['href'];

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
      
      var track_name = trackElement.getElementsByTagName('h1').first.text;
      
      List<Session> sessions = parseSessions(trackElement.getElementsByClassName('sessions'));

      Track track = new Track();
      track.trackName = track_name;
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
      conference.name = conferenceName;
      conference.logoUrlString = URL_PREFIX + conferenceLogoUrl;
      conference.shortDescription = conferenceShortDescription;
      conference.tracks = tracks;
      conference.time = conferenceTime;

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
//    Widget textSection = new Container(
//      padding: const EdgeInsets.all(12.0),
//      child: new Text(conference.name),
//    );
//    return textSection;

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
                        conference.name,
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      new Text(
                        conference.shortDescription,
                        style: new TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 18,
                        ),
                      ),
                      new Text(
                        conference.time,
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
        onTap: () {print('This row was tapped');},
      );
      return textSection;
  }


  Widget _buildConferences() {
    return new ListView.builder(
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        middle: new Text('ASCIIWWDC'),
      ),
      child: new SafeArea(
          child: hasData? _buildConferences():_buildBlank(),
      ),
    );
  }
}
