import 'package:flutter/material.dart';
import 'SessionDetailPage.dart';
import 'Session.dart';

class FavoriteTracksPage extends StatefulWidget {

  @override
  _FavoriteTracksState createState() => new _FavoriteTracksState();

}

class _FavoriteTracksState extends State<FavoriteTracksPage> {


  List<Session> _favoriteSessions;

  void _fetchFavoriteSessionsList() async {
    var sql = 'sessionIsFavorite = 1';

    var favoriteSessions = await SessionProvider.instance.getSessions(sql);

    setState(() {
      _favoriteSessions = favoriteSessions;
    });
  }

  Widget _buildSession(Session session) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => SessionDetailPage(session: session),
        ))
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6.0,horizontal: 12.0),
          child: Text(
            session.sessionTitle,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18.0,
            ),
          )
        ),
      ),
    );
  }

  Widget _buildSessionLists() {

    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => new Divider(),
        itemBuilder: (context, i)=> _buildSession(_favoriteSessions[i]),
        itemCount: _favoriteSessions.length,
    );
  }


  @override
  void initState() {
    super.initState();

    _fetchFavoriteSessionsList();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: AppBar(
        title: Text('Favorite Tracks'),
      ),
      body: SafeArea(child: _buildSessionLists()),
    );
  }
}