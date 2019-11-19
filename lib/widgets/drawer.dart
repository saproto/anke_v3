import 'package:flutter/material.dart';

class DrawerWidget extends StatefulWidget {
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
            accountName: Text('Account Name'),
            accountEmail: Text('Account Email'),
            onDetailsPressed: () {
              _toggleAccountMenu();
            },
            currentAccountPicture: CircleAvatar(backgroundImage: AssetImage('images/lake.jpg'),),
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
            title: Text(_showAccountMenu.toString()),
            onTap:() {},
          ),
          ListTile(
            title: Text('Item2'),
            onTap: () {},
          )
        ]
      )
    );
  }
}