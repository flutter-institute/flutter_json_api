// Copyright (c) 2018, Brian Armstrong. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

var httpClient = createHttpClient();

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter JSON Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(apiRoot: 'http://api.flutter.institute/'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.apiRoot}) : super(key: key);

  final String apiRoot;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}


enum ResultStatus {
  success,
  failure,
  loading,
}

class _MyHomePageState extends State<MyHomePage> {
  ResultStatus _status;
  String _name;
  List<String> _tags;


  @override
  void initState() {
    _status = null;
    _tags = [];
  }

  Future getItem(int id) async {
    setState(() {
      _status = ResultStatus.loading;
    });

    try {
      final response = await httpClient.get('${widget.apiRoot}/flutter-json.php?id=$id');
      if (response.statusCode != 200) {
        setState(() {
          _status = ResultStatus.failure;
        });
      } else {
        final Map data = JSON.decode(response.body);
        setState(() {
          _status = ResultStatus.success;

          final Map payload = data['payload'] ?? {};
          _name = payload['name'] ?? '<Name Not Found>';
          _tags = payload['tags'] ?? [];
        });
      }
    } catch (e) {
      setState(() {
        _status = ResultStatus.failure;
      });
    };
  }

  Future postItem(int id) async {
    setState(() {
      _status = ResultStatus.loading;
    });

    try {
      final response = await httpClient.post(
        '${widget.apiRoot}/flutter-json.php',
        body: JSON.encode({'name': 'New Name'}),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        setState(() {
          _status = ResultStatus.failure;
        });
      } else {
        setState(() {
          _status = ResultStatus.success;
          _name = _tags = null;
        });
      }
    } catch (e) {
      setState(() {
        _status = ResultStatus.failure;
      });
    }
  }

  Widget buildContent(BuildContext context) {
    if (_status != null) {
      switch (_status) {
        case ResultStatus.success:
          final List<Widget> children = [
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text('Result: '),
                new Text(
                  'success',
                  style: new TextStyle(color: Colors.green),
                ),
              ],
            ),
          ];

          if (_name?.isNotEmpty == true) {
            children.add(new Text('Name: $_name'));

            if (_tags?.isNotEmpty == true) {
              children.add(new Text('Tags: ${_tags.join(', ')}'));
            }
          }

          return new Column(
            children: children,
          );

        case ResultStatus.failure:
          return new Center(
            child: new Text(
              'Request Failed',
              style: new TextStyle(color: Colors.red),
            ),
          );

        case ResultStatus.loading:
          return new Center(
            child: new Text('Making API Request'),
          );
      }
    }

    return new Container();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter JSON Demo'),
      ),
      body: new Column(
        children: <Widget>[
          new ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              new MaterialButton(
                child: new Text('Get Item 1'),
                onPressed: () => getItem(0),
              ),
              new MaterialButton(
                child: new Text('Get Item 2'),
                onPressed: () => getItem(1),
              ),
            ],
          ),
          new ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              new MaterialButton(
                child: new Text('Get Bad Item'),
                onPressed: () => getItem(100),
              ),
              new MaterialButton(
                child: new Text('Post Item 1'),
                onPressed: () => postItem(0),
              ),
            ],
          ),
          new SizedBox(height: 20.0),
          buildContent(context),
        ],
      ),
    );
  }
}
