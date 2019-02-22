import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timetracker/models/activity.dart';
import 'package:timetracker/screens/login_screen.dart';
import 'package:timetracker/widgets/activity_list_tile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.hasData && snapshot.data.email != null) {
            var userPath = snapshot.data.email;
            return MyHomePage(userId: userPath);
          } else {
            return LoginScreen();
          }
        },
      ),
//      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.userId}) : super(key: key);

  final String userId;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _counter = 0;
  AppLifecycleState _notification;
  Future _loading;
  TextEditingController textEditingController;

  @override
  void initState() {
    _loading = _load();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    await Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
    var user = await FirebaseAuth.instance.currentUser();
    print('loaded with user: ${user.uid}');
  }

  @override
  Widget build(BuildContext context) {
    textEditingController = TextEditingController();

    if ((_notification == null || _notification == AppLifecycleState.resumed)) {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.userId),
        ),
        body: FutureBuilder(
            future: _loading,
            builder: (context, snapshot) {
              return StreamBuilder(
                stream: getAllActivities(widget.userId),
                builder: (context, AsyncSnapshot<List<Activity>> snapshots) {
                  if (snapshots.hasData) {
                    var activities = snapshots.data;
                    activities.sort((Activity a, Activity b) =>
                        a.getEndTime.compareTo(b.getEndTime));
                    return PageView.builder(
                      itemCount: DateTime.now().month,
                      itemBuilder: (context, int selectedMonth) {
                        var selectedMonthActivities = activities
                            .where((Activity a) =>
                                a.startTime.month ==
                                DateTime.now().month - selectedMonth)
                            .toList()
                            .reversed
                            .toList();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomScrollView(
                            slivers: <Widget>[
                              SliverToBoxAdapter(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    selectedMonthName(selectedMonth),
                                    style: TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: TextFormField(
                                  onFieldSubmitted: (String value) {
                                    textEditingController.clear();

                                    value = value.trim();

                                    if (value.length == 0) return;

                                    var now = DateTime.now();

                                    if (selectedMonthActivities.length > 0) {
                                      var lastActivity =
                                          selectedMonthActivities[0];
                                      lastActivity.endTime = now;
                                      lastActivity.save(widget.userId);
                                    }

                                    var newActivity = Activity();
                                    newActivity.title = value;
                                    newActivity.startTime = now;
                                    newActivity.save(widget.userId);
                                  },
                                  controller: textEditingController,
                                  autofocus: true,
                                  decoration:
                                      InputDecoration(hintText: "I am ..."),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return ActivityListTile(
                                      activity: selectedMonthActivities[index],
                                      isTiking: index == 0,
                                    );
                                  },
                                  childCount: selectedMonthActivities.length,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              );
            }),
      );
    } else {
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Battery efficient!!!",
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  Text(
                    "Don't worry the timer is not ticking now. But when you open app I will add the missed time and continue counting ;) for you",
                    style: TextStyle(fontSize: 32),
                  ),
                  Image.asset("images/troll.jpg"),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _onSubmit(String value) {}

  String selectedMonthName(int selectedMonth) {
    selectedMonth = DateTime.now().month - selectedMonth - 1;
    var months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[selectedMonth];
  }
}
