import 'dart:convert';
import 'dart:math';
import 'dart:ui' as prefix0;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sa_proto/widgets/drawer.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => new _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _navIndex = 0;
  List<Event> soonEvents = [];
  List<Event> monthEvents = [];
  List<Event> laterEvents = [];

  @override
  initState() {
    super.initState();
    soonEvents = [new Event()];
    refreshEvents();
    _tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
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
              itemCount: soonEvents.length,
              itemBuilder: (context, index) => eventBuilder(context, index, 1),
            ),
            onRefresh: refreshEvents,
          )),
          Center(
              child: RefreshIndicator(
                child: ListView.builder(
                  itemCount: monthEvents.length,
                  itemBuilder: (context, index) => eventBuilder(context, index, 2),
                ),
                onRefresh: refreshEvents,
              )),
          Center(
              child: RefreshIndicator(
                child: ListView.builder(
                  itemCount: laterEvents.length,
                  itemBuilder: (context, index) => eventBuilder(context, index, 3),
                ),
                onRefresh: refreshEvents,
              )),
        ]),
      ),
    );
  }

  void changeTab(int index) {
    setState(() {
      _tabController.animateTo(index);
    });
  }

  Widget eventBuilder(BuildContext context, int index, int list) {
    Event event;
    switch (list) {
      case 1: event = soonEvents[index]; break;
      case 2: event = monthEvents[index]; break;
      case 3: event = laterEvents[index]; break;
    }
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(fit: BoxFit.cover, image: AssetImage('images/lake.jpg'))),
        child: BackdropFilter(
            filter: prefix0.ImageFilter.blur(
              sigmaX: 2.0,
              sigmaY: 2.0,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: ListTile(
                onTap: () {eventDialog(context, event);},
                title: Text(event.title, style: TextStyle(color: Colors.white),),
                subtitle: RichText(
                  text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.map, color: Colors.white,),
                        ),
                        TextSpan(text: event.location + '\n', style: TextStyle(color: Colors.white)),
                        WidgetSpan(
                          child: Icon(Icons.timer, color: Colors.white,),
                        ),
                        TextSpan(
                          text: event.timeString,
                          style: TextStyle(color: Colors.white)
                        ),
                      ],
                      style: TextStyle(
                        color: Colors.black,
                      )),
                ),
              ),
            ),
          ),
      ),
    );
  }

  Future<bool> eventDialog(BuildContext context, Event event) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
          ),
          child: Column(
            children: <Widget>[
                Text(event.title, style: TextStyle(fontSize: 25),),
              MarkdownBody(data: event.description,)
            ],
          ),
        );
      }
    );
  }

  Future<void> refreshEvents() async {
    if (soonEvents == null) soonEvents = new List<Event>();
    if (monthEvents == null) monthEvents = new List<Event>();
    if (laterEvents == null) laterEvents = new List<Event>();


    final eventResult = await fetchEvents();
    final eventJson = eventResult.body;
    final events = jsonDecode(eventJson);
    setState(() {
      soonEvents.clear();
      for (var eventJSON in events) {
        Event event = Event.fromJson(eventJSON);
        if (event.soon) {soonEvents.add(event);}
        else if (event.thisMonth) {monthEvents.add(event);}
        else {laterEvents.add(event);}
      }
    });
  }

  Future<http.Response> fetchEvents() {
    return http.get('https://proto.utwente.nl/api/events/upcoming');
  }
}

class Event {
  int id;
  static DateFormat date_time = new DateFormat('E d-M H:mm');
  static DateFormat time = new DateFormat('H:mm');
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
      {this.id = 0,
        this.title = 'No events loaded',
      this.summary = '',
      this.description = '',
      this.location = '',
      this.start,
      this.end});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        id: json['id'],
        title: json['title'],
        summary: json['summary'],
        description: json['description'],
        location: json['location'],
        start: DateTime.fromMillisecondsSinceEpoch(json['start']*1000),
        end: DateTime.fromMillisecondsSinceEpoch(json['end']*1000));
  }

  Widget get image {
    return Image.network(imageUrl);
  }

  String get timeString {
    if (start.day == end.day) {
      return "${date_time.format(start)} - ${time.format(end)}";
    } else {
      return "${date_time.format(start)} - ${date_time.format(end)}";
    }
  }

  bool get soon {
    return start.difference(DateTime.now()).inDays < 8;
  }

  bool get thisMonth {
    return start.month == DateTime.now().month;
  }

  set setTitle(title) {
    this.title = title;
  }
}
