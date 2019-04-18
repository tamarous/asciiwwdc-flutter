import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'Session.dart';

class SessionDetailPage extends StatefulWidget {

  final Session session;

  SessionDetailPage({Key key, @required this.session}):super(key:key);

  @override
  _SessionDetailState createState() => new _SessionDetailState();
}

class _SessionDetailState extends State<SessionDetailPage> {

  bool ifFavorite = false;

  @override
  void initState() {
    super.initState();
    ifFavorite = widget.session.isFavorite;
  }

  @override
  Widget build(BuildContext context) {

    void toggleFavorite() async {

      widget.session.toggleFavorite();

      setState(() {
        ifFavorite = widget.session.isFavorite;
      });

    }

    Future<bool> _requestPop() {

      Navigator.of(context).pop(widget.session);

      return Future.value(false);
    }

    return WillPopScope(
        child: WebviewScaffold(
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
          withZoom: false,
          withLocalStorage: true,
        ),
        onWillPop: _requestPop,
    );
  }
}