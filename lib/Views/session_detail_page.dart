import 'package:flutter/material.dart';
import 'dart:async';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:asciiwwdc/Model/models.dart';

class SessionDetailPage extends StatefulWidget {
  final Session session;

  SessionDetailPage({Key key, @required this.session}) : super(key: key);

  @override
  _SessionDetailState createState() => new _SessionDetailState();
}

class _SessionDetailState extends State<SessionDetailPage> {

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  bool ifFavorite = false;

  @override
  void initState() {
    super.initState();
    ifFavorite = widget.session.isFavorite;
  }

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

  void shareSession(Session session) {
    Share.share('check out my website https://www.tamarous.com');
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.session.sessionTitle,
          ),
          actions: <Widget>[
            IconButton(
              icon:ifFavorite?Icon(Icons.favorite):Icon(Icons.favorite_border),
              onPressed: toggleFavorite,
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                shareSession(widget.session);
              },
            )
          ],
        ),
        body: Builder(builder: (BuildContext context) {
          return WebView(
            initialUrl: widget.session.sessionUrlString,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            onPageFinished: (String url) {
              _controller.future.then((WebViewController webViewController) {
                String removeHeadFooterScript = 'var header = document.getElementsByTagName(\"header\")[0];'+
                    'header.parentNode.removeChild(header);'+
                    'var footer = document.getElementsByTagName(\"footer\")[0];'+
                    'footer.parentNode.removeChild(footer);';

                webViewController.evaluateJavascript(removeHeadFooterScript);
              });
            },
          );
        }),
      ),
      onWillPop: _requestPop,
    );
  }
}
