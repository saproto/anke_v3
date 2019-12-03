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
  static final simpleAuth.OAuthApi _protoApi = new simpleAuth.OAuthApi(
      'saproto-api',
      oauthCredentials['id'],
      oauthCredentials['secret'],
      'https://www.proto.utwente.nl/oauth/token',
      'https://www.proto.utwente.nl/oauth/authorize',
      'nl.saproto.anke://redirect',
      scopes: ['*'],
  );

  UserInfo userInfo;

  PageController _pageController;
  int _page = 0;

  List menuItems = [
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
    _pages = menuItems.map<Widget>((menuItem) => menuItem['page']).toList();
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
                      visible: _showAccountMenu,
                      child: ListTile(
                        title: Text('Dashboard'),
                      )
                  ),
                  Visibility(
                    visible: _showAccountMenu,
                    child: ListTile(
                      title: Text('Logout'),
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