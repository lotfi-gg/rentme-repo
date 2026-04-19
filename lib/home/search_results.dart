import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentme/models/user_model.dart'; // ChatUser model
import 'package:rentme/public%20profile/public_profile.dart';

class SearchResults extends StatelessWidget {
  final String? country;
  final String? province;
  final String? townhall;

  const SearchResults({super.key, this.country, this.province, this.townhall});

  @override
  Widget build(BuildContext context) {
    // Build query dynamically based on filters
    Query query = FirebaseFirestore.instance.collection('users');
    if (country != null && country!.isNotEmpty) {
      query = query.where('country', isEqualTo: country);
    }
    if (province != null && province!.isNotEmpty) {
      query = query.where('province', isEqualTo: province);
    }
    if (townhall != null && townhall!.isNotEmpty) {
      query = query.where('townhall', isEqualTo: townhall);
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFF121212,
      ), // ✅ premium anthracite background
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.deepOrangeAccent, // ✅ custom back arrow color
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "Search Results",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          final users = snapshot.data!.docs
              .map(
                (doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                color: const Color(0xFF1E1E1E), // ✅ dark card background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: user.img != null && user.img!.isNotEmpty
                        ? Image.network(
                            user.img!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  title: Text(
                    user.agencyname ?? "No agency",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user.country ?? ''} / ${user.province ?? ''} / ${user.townhall ?? ''}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // ✅ Available cars count
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.id)
                            .collection('cars')
                            .where('status', isEqualTo: 'Available')
                            .snapshots(),
                        builder: (context, carSnapshot) {
                          if (!carSnapshot.hasData) {
                            return const SizedBox();
                          }
                          final count = carSnapshot.data!.docs.length;
                          return Text(
                            count == 0
                                ? "No available vehicles"
                                : "Available Vehicles: $count",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green, // ✅ premium accent
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.deepOrangeAccent,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicProfile(user: user),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
