import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:native_mixpanel/native_mixpanel.dart';

void main() => runApp(MyApp(
  mixpanel: Mixpanel(
    shouldLogEvents: true,
    isOptedOut: false,
  ),
));

class MyApp extends StatefulWidget {
  final Mixpanel mixpanel;

  MyApp({
    @required this.mixpanel,
  }) : assert(mixpanel != null);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _statusMessage = 'Trying to send track event';
  int count;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    count = 0;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String initStatus;
    String eventName = 'First App Open';
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await widget.mixpanel.initialize('<your-token-here>');
      await widget.mixpanel.track(eventName, jsonEncode({'Math': 'divide'}));
      initStatus = 'Event Sent: $eventName';
    } on PlatformException {
      initStatus = 'Failed to send event: $eventName';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _statusMessage = initStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('$_statusMessage\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.mixpanel.track('Added to Cart', jsonEncode({'ProductId': 'product-${count++}'}));
          },
          child: Icon(Icons.plus_one),
        ),
      ),
    );
  }
}
