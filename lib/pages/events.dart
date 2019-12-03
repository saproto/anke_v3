import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sa_proto/widgets/drawer.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => new _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with SingleTickerProviderStateMixin{
  TabController _tabController;
  int _navIndex = 0;
  List<Event> soonEvents = [];

  @override
  initState() {
    super.initState();
    soonEvents = [new Event()];
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tabController.index,
          onTap: changeTab,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              title: Text('Soon'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              title: Text('This month'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.watch_later),
              title: Text('Later'),
            )
          ],
        ),
        body: TabBarView(controller: _tabController, children: [
          Center(
              child: RefreshIndicator(
            child: ListView.builder(
              itemCount: getEventLength(),
              itemBuilder: eventBuilder,
            ),
            onRefresh: refreshEvents,
          )),
          ListView(children: [
            ListTile(
              title: Text('Event but this month'),
            )
          ]),
          ListView(children: [
            ListTile(
              title: Text('Event but later'),
            )
          ])
        ]),
      ),
    );
  }


  void changeTab(int index) {
    setState(() {
      _tabController.animateTo(index);
    });
  }

  int getEventLength() {
    if (soonEvents != null) {
      return soonEvents.length;
    } else {
      return 0;
    }
  }

  Widget eventBuilder(BuildContext context, int index) {
    Event event = soonEvents[index];
    return ListTile(
      title: Text(event.title),
      subtitle: RichText(
        text: TextSpan(
            children: [
              TextSpan(
                text: event.description + '\n',
              ),
              WidgetSpan(
                child: Icon(Icons.map),
              ),
              TextSpan(text: event.location + '\n'),
              WidgetSpan(
                child: Icon(Icons.timer),
              ),
              TextSpan(
                text: 'Start: ' +
                    event.start.toString() +
                    ' End: ' +
                    event.end.toString(),
              ),
            ],
            style: TextStyle(
              color: Colors.black,
            )),
      ),
    );
  }

  Future<void> refreshEvents() async {
    if (soonEvents == null) {
      soonEvents = new List<Event>();
    }

    final eventResult = await fetchEvents();
    final eventJson = eventResult.body;
    final events = jsonDecode(eventJson);
    setState(() {
      soonEvents.clear();
      for (var event in events) {
        soonEvents.add(new Event.fromJson(event));
      }
    });
  }

  Future<http.Response> fetchEvents() {
    return http.get('https://proto.utwente.nl/api/events/upcoming');
  }
}

class Event {
  String imageUrl;
  String title;
  String description;
  String summary;
  String location;

  DateTime start;
  DateTime end;

  bool external;
  bool educational;
  bool food;

  Event(
      {this.title = 'No events loaded',
      this.description = '',
      this.location = '',
      this.start,
      this.end});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        title: json['title'],
        description: json['description'],
        location: json['location'],
        start: DateTime.fromMicrosecondsSinceEpoch(json['start']),
        end: DateTime.fromMicrosecondsSinceEpoch(json['end']));
  }

  Widget get image {
    return Image.network(imageUrl);
  }

  set setTitle(title) {
    this.title = title;
  }
}
