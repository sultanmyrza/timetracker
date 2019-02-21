import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference userActivityCollection(String userId) {
  Firestore.instance.collection("/users/$userId/activities");
}

Stream<List<Activity>> getAllActivities(String userId) {
  return userActivityCollection(userId)
      .snapshots()
      .map<List<Activity>>((query) {
    return query.documents.map<Activity>((doc) => Activity.fromDoc(doc));
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
    activity.startTime = (doc['startTime'] as Timestamp).toDate();
    activity.endTime = (doc['endTime'] as Timestamp).toDate();
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
}
