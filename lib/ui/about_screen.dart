import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retroshare/common/drawer.dart';
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
      appBar: appBar('About', context),
      body: IndexedStack(
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
