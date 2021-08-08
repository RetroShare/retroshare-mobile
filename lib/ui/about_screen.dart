import 'dart:async';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("About",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,fontFamily: "Oxygen"),),
        centerTitle: true,
      ),
        body: SafeArea(
      child: 
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
    
    ));
  }
}
