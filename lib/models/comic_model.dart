import 'package:cloud_firestore/cloud_firestore.dart';

class Comic {
  final String? id;
  final String title;
  final String cover;
  final String author;
  final String description;
  final String genre; // Represents categories, e.g., "Action, Adventure"
  final String status; // e.g., 'Ongoing', 'Completed'
  final double rating;
  final int views;
  final int followers;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Comic({
    this.id,
    required this.title,
    required this.cover,
    required this.author,
    required this.description,
    required this.genre,
    this.status = 'Ongoing',
    this.rating = 0.0,
    this.views = 0,
    this.followers = 0,
    required this.createdAt,
    Timestamp? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  // Convert a Comic instance into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'cover': cover,
      'author': author,
      'description': description,
      'genre': genre,
      'status': status,
      'rating': rating,
      'views': views,
      'followers': followers,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a Comic instance from a Firestore document snapshot
  factory Comic.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Comic(
      id: doc.id,
      title: data['title'] ?? '',
      cover: data['cover'] ?? '',
      author: data['author'] ?? 'N/A',
      description: data['description'] ?? 'Không có mô tả.',
      genre: data['genre'] ?? 'Chưa phân loại',
      status: data['status'] ?? 'Đang cập nhật',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      views: data['views'] as int? ?? 0,
      followers: data['followers'] as int? ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }
}
