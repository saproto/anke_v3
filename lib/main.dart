import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:simple_auth/simple_auth.dart' as simpleAuth;
import 'package:simple_auth_flutter/simple_auth_flutter.dart';
import 'package:sa_proto/config/oauth.dart';

import 'widgets/drawer.dart';
import 'package:sa_proto/pages/events.dart';
import 'package:sa_proto/pages/home.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  static _MyAppState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<_MyAppState>());

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static simpleAuth.OAuthApi _protoApi;
  bool loggedIn = false;

  UserInfo userInfo;

  PageController _pageController;
  int _page = 0;

  List menuItems;

  List<Widget> _pages;

  bool _showAccountMenu = false;
  void _toggleAccountMenu() {
    setState(() {
      _showAccountMenu = !_showAccountMenu;
    });
  }

  @override
  initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    SimpleAuthFlutter.init(context);
    _protoApi = new simpleAuth.OAuthApi(
      'saproto-api',
      oauthCredentials['id'],
      oauthCredentials['secret'],
      'https://www.proto.utwente.nl/oauth/token',
      'https://www.proto.utwente.nl/oauth/authorize',
      'nl.saproto.anke://redirect',
      scopes: ['*'],
    );
    menuItems = [
      {
        'icon': Icons.home,
        'name': 'Home',
        'page': HomePage(api: _protoApi,),
      },
      {
        'icon': Icons.calendar_today,
        'name': 'Events',
        'page': EventsPage()
      }
    ];
    _pages = menuItems.map<Widget>((menuItem) => menuItem['page']).toList();

    initializeAccount();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'S.A. Proto',
      theme: new ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Scaffold(
        drawer: Drawer(
            child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(getUserName()),
                    accountEmail: Text(getUserEmail()),
                    onDetailsPressed: () {
                      _toggleAccountMenu();
                    },
                    currentAccountPicture: CircleAvatar(backgroundImage: getUserPhoto(),),
                  ),
                  Visibility(
                      visible: _showAccountMenu && _protoApi.currentOauthAccount != null && _protoApi.currentOauthAccount.isValid(),
                      child: ListTile(
                        title: Text('Dashboard'),
                      )
                  ),
                  Visibility(
                    visible: _showAccountMenu && _protoApi.currentOauthAccount != null && _protoApi.currentOauthAccount.isValid(),
                    child: ListTile(
                      title: Text('Logout'),
                      onTap: logout,
                    ),
                  ),
                  Visibility(
                    visible: _showAccountMenu && (_protoApi.currentOauthAccount == null || !_protoApi.currentOauthAccount.isValid()),
                    child: ListTile(
                      title: Text('Login'),
                      onTap: login,
                    ),
                  ),
                  Visibility(
                    visible: _showAccountMenu,
                    child: Divider(),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: menuItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Icon(menuItems[index]['icon']),
                        title: Text(
                          menuItems[index]['name'],
                          style: TextStyle(
                            color: _page == index
                                ?Theme.of(context).primaryColor
                                :Theme.of(context).textTheme.title.color,
                          ),
                        ),
                        onTap: () {
                          _pageController.jumpToPage(index);
                          Navigator.pop(context);
                        },
                      );
                    },
                  )
                ]
            )
        ),
        appBar: AppBar(
          title: Text('S.A. Proto'),
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: _pages,
        ),
      ), //new MyHomePage(title: 'S.A. Proto'),
    );
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  String getUserName() {
    return userInfo != null ? userInfo.name : 'Not logged in';
  }

  String getUserEmail() {
    return userInfo != null ? userInfo.email : '';
  }

  ImageProvider getUserPhoto() {
    return userInfo != null ? NetworkImage(userInfo.photoThumb) : AssetImage('images/lake.jpg');
  }

  Future<void> requestInfo() async {
    var request = new simpleAuth.Request(simpleAuth.HttpMethod.Get, oauthCredentials['baseurl']+'user/info');
    simpleAuth.Response<String> userInfoResult = await _protoApi.send<String>(request);
    setState(() {
      userInfo = UserInfo.fromJson(jsonDecode(userInfoResult.body));
    });
    setState(() {
      developer.log(userInfoResult.body);
    });
  }

  void initializeAccount() async {
    simpleAuth.OAuthAccount account = await _protoApi.loadAccountFromCache();

    if (account != null && account.isValid()) {
      requestInfo();
    }
  }

  void login() async {
    await _protoApi.authenticate();
    setState(() {
      requestInfo();
    });
  }

  void logout() {
    setState(() {
      _protoApi.logOut();
      userInfo = null;
    });
  }


}



class UserInfo {
  String name;
  String email;
  String rest;
  String photoThumb;

  UserInfo({this.name, this.email, this.photoThumb, this.rest});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'],
      email: json['email'],
      photoThumb: json['photo_preview'],
      rest: json.toString()
    );
  }
}