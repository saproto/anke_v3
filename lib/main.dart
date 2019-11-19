import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:simple_auth_flutter/simple_auth_flutter.dart';
import 'package:sa_proto/config/oauth.dart';

import 'widgets/drawer.dart';
import 'package:sa_proto/layouts/events.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final simpleAuth.OAuthApi protoApi = new simpleAuth.OAuthApi('saproto-api', oauthCredentials['id'], oauthCredentials['secret'], 'https://www.proto.utwente.nl/oauth/token', 'https://www.proto.utwente.nl/oauth/authorize', 'nl.saproto.anke://redirect', scopes: ['*']);

  @override
  initState() {
    super.initState();
    SimpleAuthFlutter.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'S.A. Proto',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'S.A. Proto', api: protoApi), //new MyHomePage(title: 'S.A. Proto'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.api}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final api;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //final simpleAuth.OAuthApi protoApi = new simpleAuth.OAuthApi('proto-api', '0oaoi153yaY1q7eVE0h7', 'WE3FC6pcSC1k7TAihI8ERDACAbWgcbYps_PE9v_3', 'https://dev-396343.oktapreview.com/oauth2/default/v1/token', 'https://dev-396343.oktapreview.com/oauth2/default/v1/authorize', 'https://www.oauth.com/playground/authorization-code.html', scopes: ['photo', 'offline_access']);



  @override
  Widget build(BuildContext context) {
    SimpleAuthFlutter.context = context;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      drawer: DrawerWidget(),
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              "Proto OAuth",
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login(widget.api);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Logout'),
            onTap: () {
              logout(widget.api);
            },
          ),
          ListTile(
            title: Text('Request info'),
            onTap: requestInfo
          )
        ],
      ),
    );
  }

  void requestInfo() {
    setState(() {

    });
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new FlatButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login(simpleAuth.AuthenticatedApi api) async {
    try {
      var success = await api.authenticate();
      showMessage("Logged in success: $success");
    } catch (e) {
      showError(e);
    }
  }

  void logout(simpleAuth.AuthenticatedApi api) async {
    await api.logOut();
    showMessage("Logged out");
  }
}