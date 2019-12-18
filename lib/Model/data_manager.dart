import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:asciiwwdc/Model/models.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

class DataManager {
  factory DataManager() => _getInstance();
  static DataManager _instance;

  static DataManager get instance => _getInstance();

  DataManager._internal();

  static DataManager _getInstance() {
    if (_instance == null) {
      _instance = DataManager._internal();
    }

    return _instance;
  }
  List<Conference> _conferences;
  String _databaseForSessionsFullPath;
  String _databaseForTracksFullPath;
  String _databaseForConferencesFullPath;

  Future<String> get databaseForSessionsFullPath async {
    if (_databaseForSessionsFullPath != null) {
      return _databaseForSessionsFullPath;
    }

    var databasePath = await getDatabasesPath();
    _databaseForSessionsFullPath = join(databasePath, 'sessions.db');

    if (await Directory(dirname(_databaseForSessionsFullPath)).exists()) {
    } else {
      try {
        await Directory(dirname(_databaseForSessionsFullPath)).create();
      } catch (e) {
        _databaseForSessionsFullPath = null;
      }
    }

    return _databaseForSessionsFullPath;
  }

  Future<String> get databaseForTracksFullPath async {
    if (_databaseForTracksFullPath != null) {
      return _databaseForTracksFullPath;
    }

    var databasePath = await getDatabasesPath();
    _databaseForTracksFullPath = join(databasePath, 'tracks.db');

    if (await Directory(dirname(_databaseForTracksFullPath)).exists()) {
    } else {
      try {
        await Directory(dirname(_databaseForTracksFullPath)).create();
      } catch (e) {
        _databaseForTracksFullPath = null;
        print(e);
      }
    }

    return _databaseForTracksFullPath;
  }

  Future<String> get databaseForConferencesFullPath async {
    if (_databaseForConferencesFullPath != null) {
      return _databaseForConferencesFullPath;
    }

    var databasePath = await getDatabasesPath();
    _databaseForConferencesFullPath = join(databasePath, 'conferences.db');

    if (await Directory(dirname(_databaseForConferencesFullPath)).exists()) {
    } else {
      try {
        await Directory(dirname(_databaseForConferencesFullPath)).create();
      } catch (e) {
        _databaseForConferencesFullPath = null;
        print(e);
      }
    }

    return _databaseForConferencesFullPath;
  }

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

  Future<List<Conference>> loadConferences() async {
    Response response = await Dio().get(urlPrefix);
    return loadConferencesFromNetworkResponse(response);
  }
}
