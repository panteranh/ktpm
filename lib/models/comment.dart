import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String? id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final int likes;
  final Timestamp createdAt;

  Comment({
    this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    this.likes = 0,
    required this.createdAt,
  });

   // Convert a Comment instance into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'likes': likes,
      'createdAt': createdAt,
    };
  }

  // Create a Comment instance from a Firestore document snapshot
  factory Comment.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Người dùng ẩn danh',
      userAvatar: data['userAvatar'] as String?,
      text: data['text'] ?? '',
      likes: data['likes'] as int? ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
