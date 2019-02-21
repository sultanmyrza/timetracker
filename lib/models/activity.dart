import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference userActivityCollection(String userId) {
  return Firestore.instance.collection("/users/$userId/activities");
}

Stream<List<Activity>> getAllActivities(String userId) {
  return userActivityCollection(userId)
      .snapshots()
      .map<List<Activity>>((query) {
    return query.documents
        .map<Activity>((doc) => Activity.fromDoc(doc))
        .toList();
  });
}

class Activity {
  DocumentReference _docRef;
  String title;
  DateTime startTime;
  DateTime endTime;

  Activity();

  factory Activity.fromDoc(DocumentSnapshot doc) {
    final activity = Activity();
    activity._docRef = doc.reference;
    activity.title = (doc['title'] as String);
    try {
      activity.startTime = (doc['startTime'] as Timestamp).toDate();
      var endTimeStamp = (doc['endTime'] as Timestamp);
      activity.endTime = endTimeStamp?.toDate();
    } catch (e) {
      print(e.toString());
    }
    return activity;
  }

  Future<void> save(String userId) async {
    final data = {
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
    };

    if (_docRef == null) {
      _docRef = await userActivityCollection(userId).add(data);
    } else {
      await _docRef.setData(data);
    }
  }

  String getActivityDuration() {
    var startTime = this.startTime;
    var endTime = this.endTime ?? DateTime.now();

    var duration = endTime.difference(startTime);
    int seconds = duration.inSeconds;

    int hh = seconds ~/ 3600;
    seconds %= 3600;
    int mm = seconds ~/ 60;
    seconds %= 60;

    // TODO: printf formating so 0:13:0 will be 00:13:00
    String result = "$seconds sec(s)";
    if (hh > 0 || mm > 0) {
      result = "$mm min(s)" + result;
    }
    if (hh > 0) {
      result = "$hh hour(s)" + result;
    }
    return result;
  }

  DateTime get getEndTime =>
      this.endTime == null ? DateTime.now() : this.endTime;
}
