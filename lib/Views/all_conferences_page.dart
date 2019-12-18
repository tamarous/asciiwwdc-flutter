import 'package:asciiwwdc/Model/models.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

import 'conference_detail_page.dart';
import 'favorite_sessions_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

class AllConferencesPage extends StatefulWidget {
  @override
  AllConferencesState createState() => AllConferencesState();
}

class AllConferencesState extends State<AllConferencesPage> {
  List<Conference> _conferences;

  Future _future;

  static const String urlPrefix = 'https://www.asciiwwdc.com';

  List<Session> parseSessions(List<dom.Element> sessionElements) {
    List<Session> sessions = List<Session>();

    for (int i = 0; i < sessionElements.length; i++) {
      dom.Element sessionElement = sessionElements[i];

      var aElements = sessionElement.getElementsByTagName('a');

      for (int j = 0; j < aElements.length; j++) {
        dom.Element aElement = aElements[j];
        Session session = Session();
        session.sessionUrlString = aElement.attributes['href'];
        session.sessionTitle = aElement.attributes['title'];

        sessions.add(session);
      }
    }

    return sessions;
  }

  List<Track> parseTracks(List<dom.Element> trackElements) {
    List<Track> tracks = List<Track>();

    for (int i = 0; i < trackElements.length; i++) {
      dom.Element trackElement = trackElements[i];

      var trackName = trackElement.getElementsByTagName('h1').first.text;

      List<Session> sessions =
          parseSessions(trackElement.getElementsByClassName('sessions'));

      Track track = Track();
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
    List<Conference> conferences = List();

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

      Conference conference = Conference();
      conference.conferenceName = conferenceName;
      conference.conferenceLogoUrl = urlPrefix + conferenceLogoUrl;
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
      _conferences[i] =
          await ConferenceProvider.instance.insert(_conferences[i]);
    }

    await ConferenceProvider.instance.close();
  }

  void checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
    } else if (connectivityResult == ConnectivityResult.wifi) {
    } else if (connectivityResult == ConnectivityResult.none) {}
  }

  Future<List<Conference>> loadConferences() async {
    checkInternetConnection();

    Response response = await Dio().get(urlPrefix);
    _future = loadConferencesFromNetworkResponse(response);

    // _future = loadConferencesFromDatabase();
    // _future.timeout(Duration(seconds: 3), onTimeout: () async {
    //   Response response = await Dio().get(urlPrefix);
    //   _future = loadConferencesFromNetworkResponse(response);
    // });

    return _future;
  }

  Widget _buildCard(Conference conference) {
    Widget card = InkWell(
        child: Card(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(252, 250, 242, 1.0),
            ),
            height: 160,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.0),
                  child: Center(
                    child: Text(
                      conference.conferenceName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color.fromRGBO(67, 67, 67, 1.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.0),
                  child: Center(
                    child: Text(
                      conference.conferenceShortDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        color: Color.fromRGBO(130, 130, 130, 1.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 6.0),
                  child: Center(
                    child: Text(
                      conference.conferenceTime != null
                          ? _formatTime(conference.conferenceTime)
                          : 'Unknown Time',
                      style: TextStyle(
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
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConferenceDetailPage(
                    conference: conference,
                  )),
        );
      },
    );

    return card;
  }

  String _formatTime(String originalString) {
    var times = originalString.split("T");
    return "${times[0]} ${times[1]}";
  }

  Widget _buildConferences(List<Conference> conferences) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: conferences.length,
      itemBuilder: (context, i) {
        return _buildCard(conferences[i]);
      },
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

    _future = loadConferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ASCIIWWDC-Flutter'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SearchPage(conferences: _conferences)));
              }),
          IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FavoriteSessionssPage()));
              }),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsPage()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Conference>>(
          builder: (context, AsyncSnapshot<List<Conference>> snap) {
            if (snap.connectionState == ConnectionState.none ||
                snap.connectionState == ConnectionState.waiting ||
                snap.connectionState == ConnectionState.active) {
              return _buildBlank();
            } else if (snap.connectionState == ConnectionState.done) {
              if (snap.hasError) {
                return _buildBlank();
              } else if (snap.hasData) {
                _conferences = snap.data;
                //saveAllConferencesToDatabase();
                return _buildConferences(_conferences);
              } else {
                return _buildBlank();
              }
            }
          },
          future: _future,
        ),
      ),
    );
  }
}
