import 'package:cloud_firestore/cloud_firestore.dart';

/// Chapter Model for Firestore
class Chapter {
  final String? id; // Document ID from Firestore
  final int chapterNumber;
  final String title;
  final List<String> pages; // List of image URLs for the chapter pages
  final Timestamp createdAt;

  Chapter({
    this.id,
    required this.chapterNumber,
    required this.title,
    required this.pages,
    required this.createdAt,
  });

  // Convert a Chapter instance into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'chapterNumber': chapterNumber,
      'title': title,
      'pages': pages,
      'createdAt': createdAt,
    };
  }

  // Create a Chapter instance from a Firestore document snapshot
  factory Chapter.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Chapter(
      id: doc.id,
      chapterNumber: data['chapterNumber'] as int? ?? 0,
      title: data['title'] as String? ?? 'Chương không tên',
      pages: List<String>.from(data['pages'] ?? []),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
