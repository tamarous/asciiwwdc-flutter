import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'Session.dart';

class TrackDetailPage extends StatefulWidget {

  Session session;

  TrackDetailPage({Key key, @required this.session}):super(key:key);

  @override
  _TrackDetailState createState() => new _TrackDetailState();
}

class _TrackDetailState extends State<TrackDetailPage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new WebviewScaffold(
        url: widget.session.urlString,
        appBar: AppBar(
          title: Text(
            widget.session.sessionTitle,
          ),
        ),
        withZoom: true,
        withLocalStorage: true,
    );
  }
}