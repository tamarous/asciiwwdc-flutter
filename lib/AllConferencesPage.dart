import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'Conference.dart';
import 'Session.dart';
import 'Track.dart';
import 'SearchPage.dart';
import 'ConferenceDetailPage.dart';
import 'FavoriteSessionsPage.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:connectivity/connectivity.dart';

class AllConferencesPage extends StatefulWidget {
  @override
  AllConferencesState createState() => new AllConferencesState();
}

class AllConferencesState extends State<AllConferencesPage> {
  List<Conference> _conferences;

  bool _hasLoadedData = false;

  static const String URL_PREFIX = 'https://www.asciiwwdc.com';

  List<Session> parseSessions(List<dom.Element> sessionElements) {
    List<Session> sessions = new List<Session>();

    for (int i = 0; i < sessionElements.length; i++) {
      dom.Element sessionElement = sessionElements[i];

      var aElements = sessionElement.getElementsByTagName('a');

      for (int j = 0; j < aElements.length; j++) {
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

    for (int i = 0; i < trackElements.length; i++) {
      dom.Element trackElement = trackElements[i];

      var trackName = trackElement.getElementsByTagName('h1').first.text;

      List<Session> sessions =
          parseSessions(trackElement.getElementsByClassName('sessions'));

      Track track = new Track();
      track.trackName = trackName;
      track.sessions = sessions;

      tracks.add(track);
    }
    return tracks;
  }

  Future<List<Conference>> loadConferencesFromDatabase() async {
    List<Conference> conferences;

    conferences = await ConferenceProvider.instance.getConferences('1 = 1');

    await ConferenceProvider.instance.close();

    return conferences;
  }

  Future<List<Conference>> loadConferencesFromNetworkResponse(
      Response response) async {
    List<Conference> conferences = new List();

    var document = parser.parse(response.data);

    var conferenceElements = document.getElementsByClassName('conference');

    for (int i = 0; i < conferenceElements.length; i++) {
      dom.Element conferenceElement = conferenceElements[i];
      var trackElements = conferenceElement.getElementsByClassName('track');
      List<Track> tracks = parseTracks(trackElements);

      var conferenceName =
          conferenceElement.getElementsByTagName('h1').first.text;
      var conferenceLogoUrl =
          conferenceElement.getElementsByTagName('img').first.attributes['src'];
      var conferenceShortDescription =
          conferenceElement.getElementsByTagName('h2').first.text;
      var conferenceTime = conferenceElement
          .getElementsByTagName('time')
          .first
          .attributes['content'];

      Conference conference = new Conference();
      conference.conferenceName = conferenceName;
      conference.conferenceLogoUrl = URL_PREFIX + conferenceLogoUrl;
      conference.conferenceShortDescription = conferenceShortDescription;
      conference.tracks = tracks;
      conference.conferenceTime = conferenceTime;

      for (int j = 0; j < conference.tracks.length; j++) {
        for (int k = 0; k < conference.tracks[j].sessions.length; k++) {
          conference.tracks[j].sessions[k].sessionConferenceName =
              conferenceName;
        }
      }

      conferences.add(conference);
    }

    return conferences;
  }

  void saveAllConferencesToDatabase() async {
    for (int i = 0; i < _conferences.length; i++) {
      await ConferenceProvider.instance.insert(_conferences[i]);
    }

    await ConferenceProvider.instance.close();
  }

  void checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      
    } else if (connectivityResult == ConnectivityResult.wifi) {
    
    } else if (connectivityResult == ConnectivityResult.none) {
      
    }
  }

  void loadConferences() async {
    checkInternetConnection();

    List<Conference> conferences;

    conferences = await loadConferencesFromDatabase();

    if (conferences == null || conferences.isEmpty) {

      try {
        Response response = await Dio().get(URL_PREFIX);
        conferences = await loadConferencesFromNetworkResponse(response);

        setState(() {
          _conferences = conferences;
          _hasLoadedData = true;
        });

        saveAllConferencesToDatabase();
      } catch (e) {
        print(e);
      }
    } else {

      setState(() {
        _conferences = conferences;
        _hasLoadedData = true;
      });
    }
  }

  Widget _buildCard(Conference conference) {

    Widget card = GestureDetector(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(252, 250, 242, 1.0)),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new Container(
                  margin: EdgeInsets.only(left: 6.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 6.0),
                        child: Center(
                          child: new Text(
                            conference.conferenceName,
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Color.fromRGBO(67, 67, 67, 1.0),
                            ),
                          ),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 6.0),
                        child: Center(
                          child: new Text(
                            conference.conferenceShortDescription,
                            style: new TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color: Color.fromRGBO(130, 130, 130, 1.0),
                            ),
                          ),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 6.0),
                        child: Center(
                          child: new Text(
                            conference.conferenceTime != null?conference.conferenceTime:'Unknown Time',
                            style: new TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color: Color.fromRGBO(130, 130, 130, 1.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new ConferenceDetailPage(
                    tracks: conference.tracks,
                  )),
        );
      },
    );

    return card;
  }

  Widget _buildConferences() {
    return new ListView.builder(
      shrinkWrap: true,
      itemCount: _conferences.length,
      itemBuilder: (context, i) {
        return _buildCard(_conferences[i]);
      },
      padding: const EdgeInsets.all(12.0),
    );
  }

  Widget _buildBlank() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void initState() {
    super.initState();

    loadConferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text('ASCIIWWDC-Flutter'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new SearchPage(
                            conferences:
                                _hasLoadedData ? _conferences : new List<String>())));
              }),
          new IconButton(
              icon: new Icon(Icons.favorite_border),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => FavoriteSessionssPage()));
              }),
        ],
      ),
      body: new SafeArea(child: _hasLoadedData ? _buildConferences() : _buildBlank()),
    );
  }
}
