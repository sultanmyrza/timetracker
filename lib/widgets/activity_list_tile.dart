import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timetracker/models/activity.dart';

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
  Timer _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('_ActivityListTileState.initState');
    if (widget.isTiking) {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        if (mounted) {
          print('update the duration in ${widget.activity.title}');
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
    print('_ActivityListTileState.dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          Text(widget.activity.title),
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
                  widget.isTiking
                      ? Text("--:--:--")
                      : Text(formatDateHhMmSs(widget.activity.getEndTime)),
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
