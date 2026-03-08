import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có người dùng nào tham gia.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data();
              // Safe access to data
              final String email = userData['email'] ?? 'Không có email';
              final String name = userData['displayName'] ?? 'Người dùng mới';
              final String? photoUrl = userData['photoURL'];
              final dynamic rawCreatedAt = userData['createdAt'];
              
              String dateStr = 'N/A';
              if (rawCreatedAt is Timestamp) {
                dateStr = DateFormat('dd/MM/yyyy').format(rawCreatedAt.toDate());
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.deepPurple.shade100,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                    child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person, color: Colors.deepPurple) : null,
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('Tham gia: $dateStr', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Actions like banning or changing roles can go here
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
