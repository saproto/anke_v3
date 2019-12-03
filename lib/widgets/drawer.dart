import 'package:flutter/material.dart';
import 'package:sa_proto/main.dart';
import 'package:sa_proto/pages/events.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key key, this.userInfo}) : super(key: key);

  UserInfo userInfo;

  @override
  _DrawerWidget createState() => new _DrawerWidget();
}

class _DrawerWidget extends State<DrawerWidget> {

  bool _showAccountMenu = false;
  void _toggleAccountMenu() {
    setState(() {
      _showAccountMenu = !_showAccountMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
          ListTile(
            title: Text('Events'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventsPage()));
            },
          )
        ]
      )
    );
  }

  String getUserName() {
    return widget.userInfo != null ? widget.userInfo.name : 'Not logged in';
  }

  String getUserEmail() {
    return widget.userInfo != null ? widget.userInfo.email : '';
  }

  ImageProvider getUserPhoto() {
    return widget.userInfo != null ? NetworkImage(widget.userInfo.photoThumb) : AssetImage('images/lake.jpg');
  }
}