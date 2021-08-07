import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retroshare/common/styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  num _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(children: [
        Container(
          height: appBarHeight,
          child: Row(
            children: <Widget>[
              Visibility(
                visible: true,
                child: Container(
                  width: personDelegateHeight,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  child: Text(
                    'About',
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _stackToView,
            children: [
              WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: 'https://retrosharedocs.readthedocs.io/en/latest/',
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                onPageFinished: _handleLoad,
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ]),
    ));
  }
}
