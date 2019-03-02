import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timetracker/models/activity.dart';
import 'package:timetracker/screens/activity_detail_screen.dart';

class ActivityListTile extends StatefulWidget {
  final Activity activity;
  final bool isTiking;

  ActivityListTile({
    @required this.activity,
    @required this.isTiking,
  });

  @override
  _ActivityListTileState createState() => _ActivityListTileState();
}

class _ActivityListTileState extends State<ActivityListTile> {
  static const platform = const MethodChannel('com.u2731.timetracker/scheduled_notification');
  Timer _timer;

  Future<void> scheduleNotification() async {
    try {
      final String responseMessage = await platform.invokeMethod("scheduleNotification");
      print(responseMessage);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> cancelScheduledNotification() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isTiking) {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        if (mounted) {
          setState(() {});
        } else {
          _timer.cancel();
          print("cancel the timer");
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(ActivityDetailScreen.route(
          activity: widget.activity,
        ));
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.activity.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text("start time"),
                      Text(formatDateHhMmSs(widget.activity.startTime)),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text("end time"),
                      widget.isTiking ? Text("--:--:--") : Text(formatDateHhMmSs(widget.activity.getEndTime)),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text("Duration"),
                      Text(widget.activity.getActivityDuration()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateHhMmSs(DateTime date) {
    return "${date.hour}:${date.minute}:${date.second}";
  }

  String getDuration(Activity activity) {
    var startTime = activity.startTime;
    var endTime = activity.endTime ?? DateTime.now();

    var duration = endTime.difference(startTime);
    int seconds = duration.inSeconds;

    int hh = seconds ~/ 3600;
    seconds %= 3600;
    int mm = seconds ~/ 60;
    seconds %= 60;

    // TODO: printf formating so 0:13:0 will be 00:13:00
    String result = "$mm min(s) $seconds sec(s)";
    if (hh > 0) {
      result = "$hh hour(s)" + result;
    }
    return result;
  }
}
