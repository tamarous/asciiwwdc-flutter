import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'Session.dart';

class TrackDetailPage extends StatefulWidget {

  final Session session;

  TrackDetailPage({Key key, @required this.session}):super(key:key);

  @override
  _TrackDetailState createState() => new _TrackDetailState();
}

class _TrackDetailState extends State<TrackDetailPage> {

  @override
  Widget build(BuildContext context) {

    bool ifFavorite = widget.session.isFavorite;

    void toggleFavorite() {
      widget.session.isFavorite = !widget.session.isFavorite;
      setState(() {
        ifFavorite = widget.session.isFavorite;
      });
    }

    return new WebviewScaffold(
        url: widget.session.sessionUrlString,
        appBar: AppBar(
          title: Text(
            widget.session.sessionTitle,
          ),
          actions: <Widget>[
            IconButton(
              icon:ifFavorite?Icon(Icons.favorite):Icon(Icons.favorite_border),
              onPressed: toggleFavorite,
            ) 
          ],
        ),
        withZoom: true,
        withLocalStorage: true,
    );
  }
}