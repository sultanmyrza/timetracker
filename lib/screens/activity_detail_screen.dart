import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timetracker/models/activity.dart';

class ActivityDetailScreen extends StatefulWidget {
  static Route<dynamic> route({Activity activity}) {
    return MaterialPageRoute(
      builder: (BuildContext context) => ActivityDetailScreen(
            activity: activity,
          ),
    );
  }

  Activity activity;

  ActivityDetailScreen({this.activity});

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit"),
      ),
      body: Builder(builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  widget.activity.title,
                  style: Theme.of(context).textTheme.display2,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.activity.startTimeHhMmSs,
                  style: Theme.of(context).textTheme.display1,
                ),
                IconButton(
                    icon: Icon(Icons.mode_edit),
                    onPressed: () {
                      showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  widget.activity.startTime))
                          .then((TimeOfDay selectedTime) async {
                        var startTime = widget.activity.startTime;

                        var updatedStartTime = DateTime(
                          startTime.year,
                          startTime.month,
                          startTime.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        widget.activity.startTime = updatedStartTime;

                        var currentUser =
                            await FirebaseAuth.instance.currentUser();
                        try {
                          await widget.activity.save(currentUser.email);
                        } on Exception catch (e) {
                          // TODO fix later related to firebase save
                        }

                        // TODO: use firebase
                        setState(() {});
                        final snackBar = SnackBar(
                            content: Text(
                                'Start time update to ${selectedTime.toString()}'));
                        Scaffold.of(context).showSnackBar(snackBar);
                      });
                    })
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.activity.endTimeHhMmSs,
                  style: Theme.of(context).textTheme.display1,
                ),
                IconButton(
                    icon: Icon(Icons.mode_edit),
                    onPressed: () {
                      showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  widget.activity.getEndTime))
                          .then((TimeOfDay selectedTime) async {
                        var endTime = widget.activity.getEndTime;

                        var updatedEndTime = DateTime(
                          endTime.year,
                          endTime.month,
                          endTime.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        widget.activity.endTime = updatedEndTime;

                        var currentUser =
                            await FirebaseAuth.instance.currentUser();
                        try {
                          await widget.activity.save(currentUser.email);
                        } on Exception catch (e) {
                          // TODO fix later related to firebase save

                        }

                        // TODO: use firebase
                        setState(() {});
                        final snackBar = SnackBar(
                            content: Text(
                                'End time update to ${selectedTime.toString()}'));
                        Scaffold.of(context).showSnackBar(snackBar);
                      });
                    }),
              ],
            ),
            Text(
              widget.activity.getActivityDuration(),
              style: Theme.of(context).textTheme.display1,
            )
          ],
        );
      }),
    );
  }

  _showTimePicker() {}
}
