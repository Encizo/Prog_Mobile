import 'package:cloud_firestore/cloud_firestore.dart';

class FollowedNews {
  final String newsId;
  final String userId;
  final Map<String, String> notes;
  final DateTime followedAt;
  final String title;
  final String eventType;
  final String subEventType;
  final String actor1;
  final String location;
  final String country;
  final DateTime eventDate;

  FollowedNews({
    required this.newsId,
    required this.userId,
    required this.notes,
    required this.followedAt,
    required this.title,
    required this.eventType,
    required this.subEventType,
    required this.actor1,
    required this.location,
    required this.country,
    required this.eventDate,
  });

  factory FollowedNews.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return FollowedNews(
      newsId: data?['newsId'],
      userId: data?['userId'],
      notes: Map<String, String>.from(data?['notes'] ?? {}),
      followedAt: (data?['followedAt'] as Timestamp).toDate(),
      title: data?['title'] ?? '',
      eventType: data?['eventType'] ?? '',
      subEventType: data?['subEventType'] ?? '',
      actor1: data?['actor1'] ?? '',
      location: data?['location'] ?? '',
      country: data?['country'] ?? '',
      eventDate: (data?['eventDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'newsId': newsId,
      'userId': userId,
      'notes': notes,
      'followedAt': Timestamp.fromDate(followedAt),
      'title': title,
      'eventType': eventType,
      'subEventType': subEventType,
      'actor1': actor1,
      'location': location,
      'country': country,
      'eventDate': Timestamp.fromDate(eventDate),
    };
  }
}