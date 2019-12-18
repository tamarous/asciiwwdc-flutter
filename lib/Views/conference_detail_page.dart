import 'package:flutter/material.dart';

import 'package:asciiwwdc/Model/models.dart';
import 'session_detail_page.dart';

class ConferenceDetailPage extends StatefulWidget {
  final Conference conference;

  ConferenceDetailPage({Key key, @required this.conference}):super(key:key);

  @override
  _ConferenceDetailState createState() => _ConferenceDetailState();
}

class _ConferenceDetailState extends State<ConferenceDetailPage>{
  Widget _buildRow(int row, int column) {

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6.0,horizontal: 12.0),
                child: Text(
                  widget.conference.tracks[row].sessions[column].sessionTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: widget.conference.tracks[row].sessions[column].isFavorite?Icon(Icons.favorite):Icon(Icons.favorite_border),
              onPressed: () {
                widget.conference.tracks[row].sessions[column].toggleFavorite();
                setState(() {
                  widget.conference.tracks[row].sessions[column] = widget.conference.tracks[row].sessions[column];
                });
              },
              iconSize: 20,
            ),
          ],
        ),
      ),
      onTap: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SessionDetailPage(session: widget.conference.tracks[row].sessions[column],)),);
      },
    );
  }


  List<Widget> _buildExpansionTileChildren(int row) {
    List<Widget> tiles = [];

    for(int col = 0; col < widget.conference.tracks[row].sessions.length;col++) {
      tiles.add(_buildRow(row, col));
    }

    return tiles;
  }

  Widget _buildExpansionTile(int row) {

    return ExpansionTile(
      title: Text(
        widget.conference.tracks[row].trackName,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 20.0,
        ),
        ),
      key: PageStorageKey(widget.conference.tracks[row]),
      children: _buildExpansionTileChildren(row),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: _sliverBuilder,
        body: SafeArea(
          child: ListView.builder(
            itemBuilder: (BuildContext context, int row)=>_buildExpansionTile(row),
            itemCount: widget.conference.tracks.length,
          ),
        ),
      ),
    );
  }


  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        primary: true,
        forceElevated: false,
        automaticallyImplyLeading: true,
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        snap: false,
        expandedHeight: 200.0,
        floating: true,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(widget.conference.conferenceName),
          background: Image.network(widget.conference.conferenceLogoUrl,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    ];
  }
}