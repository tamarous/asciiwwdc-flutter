import 'package:flutter/material.dart';
import 'package:asciiwwdc/Model/models.dart';
import 'conference_detail_page.dart';
import 'favorite_sessions_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

class AllConferencesPage extends StatefulWidget {
  @override
  AllConferencesState createState() => AllConferencesState();
}

class AllConferencesState extends State<AllConferencesPage> {
  Future _future;

  List<Conference> _conferences;
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
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
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
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
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
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
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

    _future = DataManager.instance.loadConferences();
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
