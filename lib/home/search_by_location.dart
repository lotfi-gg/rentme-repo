import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentme/models/user_model.dart'; // ChatUser model
import 'package:rentme/public%20profile/public_profile.dart'; // PublicProfile widget

class SearchByLocation extends StatelessWidget {
  final String? country;
  final String? province;
  final String? townhall;

  const SearchByLocation({
    super.key,
    this.country,
    this.province,
    this.townhall,
  });

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
      appBar: AppBar(title: const Text("Search Results")),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
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
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: user.img != null && user.img!.isNotEmpty
                      ? Image.network(
                          user.img!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person),
                  title: Text(user.agencyname ?? "No agency"),
                  subtitle: Text(
                    "${user.country} / ${user.province} / ${user.townhall}",
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
