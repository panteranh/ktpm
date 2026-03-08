import 'package:cloud_firestore/cloud_firestore.dart';

class Comic {
  final String? id;
  final String title;
  final String cover;
  final String author;
  final String description;
  final String genre;
  final Timestamp createdAt;

  Comic({
    this.id,
    required this.title,
    required this.cover,
    required this.author,
    required this.description,
    required this.genre,
    required this.createdAt,
  });

  // Convert a Comic instance into a Map. The keys must correspond to the names of the fields in Firestore.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'cover': cover,
      'author': author,
      'description': description,
      'genre': genre,
      'createdAt': createdAt,
    };
  }

  // Create a Comic instance from a Firestore document snapshot.
  factory Comic.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Comic(
      id: doc.id,
      title: data['title'] ?? '',
      cover: data['cover'] ?? '',
      author: data['author'] ?? 'N/A',
      description: data['description'] ?? 'Không có mô tả.',
      genre: data['genre'] ?? 'Chưa phân loại',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
