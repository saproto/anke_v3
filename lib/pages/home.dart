import 'package:flutter/material.dart';
import 'package:sa_proto/main.dart';
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:sa_proto/config/oauth.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.api}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final api;

  final icon = Icons.home;
  final name = 'Home';


  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new ListView(
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
          ),
          ListTile(
              title: Text('Gone')
          )
        ],
      );
  }

  Future<void> requestInfo() async {
    var request = new simpleAuth.Request(simpleAuth.HttpMethod.Get, oauthCredentials['baseurl']+'user/info');
    simpleAuth.Response<String> userInfoResult = await widget.api.send<String>(request);
    MyApp.of(context).setState(() {
      MyApp.of(context).userInfo = UserInfo.fromJson(jsonDecode(userInfoResult.body));
    });
    setState(() {
      showMessage(userInfoResult.body);
      developer.log(userInfoResult.body);
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

  void login(simpleAuth.OAuthApi api) async {
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