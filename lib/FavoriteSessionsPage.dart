import 'package:flutter/material.dart';
import 'SessionDetailPage.dart';
import 'Session.dart';

class FavoriteSessionssPage extends StatefulWidget {

  @override
  _FavoriteSessionsState createState() => new _FavoriteSessionsState();

}

class _FavoriteSessionsState extends State<FavoriteSessionssPage> {


  List<Session> _favoriteSessions;

  bool _hasData = false;

  Future _showSessionDetail(Session session) async {
    bool oldFavorite = session.isFavorite;

    Session updatedSession = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SessionDetailPage(session: session)));

    if (updatedSession.isFavorite != oldFavorite) {
      _fetchFavoriteSessionsList();
    }

  }

  void _fetchFavoriteSessionsList() async {
    var sql = 'sessionIsFavorite = 1';

    var favoriteSessions = await SessionProvider.instance.getSessions(sql);

    setState(() {
      _favoriteSessions = favoriteSessions;

      _hasData = true;
    });
  }

  Widget _buildSession(Session session) {
    return GestureDetector(
      onTap: () {
        _showSessionDetail(session);
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6.0,horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 4.0),
                child: Text(
                  session.sessionTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  session.sessionConferenceName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              )
            ],
          ),
          
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

  Widget _buildBlank() {
    return Center(
      child: Text(
        'None',
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 18.0,
        ),
      ),
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
      body: SafeArea(
          child: _hasData?_buildSessionLists():_buildBlank(),
      ),
    );
  }
}