import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:rentme/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/public%20profile/public_avaiable_cars.dart';
import 'package:rentme/public%20profile/public_rented_cars.dart';
import 'package:intl/intl.dart';

class PublicProfile extends StatefulWidget {
  final ChatUser user;
  const PublicProfile({super.key, required this.user});

  @override
  State<PublicProfile> createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  TextEditingController comment = TextEditingController();
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  PageController pageController = PageController();
  int currentIndex = 0;

  void _showRatingDialog(BuildContext context) {
    int selectedStars = 0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rate this service"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedStars = index + 1;
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser!;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.id)
                    .collection('ratings')
                    .doc(currentUser.uid)
                    .set({
                      'stars': selectedStars,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.agencyname!)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButtons(),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 50,
            child: Image.asset('images/user logo.png', height: 150),
          ),
          const SizedBox(height: 10),

          // Ratings section
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.user.id)
                .collection('ratings')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                // 👇 No ratings yet
                return Column(
                  children: [
                    InkWell(
                      onTap: () => _showRatingDialog(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return const Icon(
                            Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Ratings: 0'), // 👈 Always show count
                  ],
                );
              }

              // 👇 There are ratings
              final ratings = docs
                  .map(
                    (doc) =>
                        (doc.data() as Map<String, dynamic>)['stars'] as int,
                  )
                  .toList();

              final avgRating =
                  ratings.reduce((a, b) => a + b) / ratings.length;

              return Column(
                children: [
                  InkWell(
                    onTap: () => _showRatingDialog(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < avgRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Ratings: ${ratings.length}'), // 👈 Dynamic count
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          // 👇 Navigation bar directly under ratings
          NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (value) {
              setState(() {
                currentIndex = value;
                pageController.jumpToPage(value);
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Iconsax.car),
                label: 'Available',
              ),
              NavigationDestination(icon: Icon(Iconsax.car5), label: 'Rented'),
            ],
          ),

          // 👇 Expanded PageView for cars
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              children: const [PublicAvaiableCars(), PublicRentedCars()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Location button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.45),
            SizedBox(width: MediaQuery.of(context).size.width * 0.2),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              child: FloatingActionButton(
                heroTag: "locationBtn",
                mini: true,
                onPressed: () async {
                  final lat = widget.user.latitude;
                  final lng = widget.user.longitude;
                  if (lat != null && lng != null) {
                    final Uri mapsUri = Uri.parse(
                      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
                    );
                    try {
                      await launchUrl(
                        mapsUri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Could not open location"),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No location available")),
                    );
                  }
                },
                child: const Icon(Icons.location_on, color: Colors.red),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Call button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: FloatingActionButton.extended(
                heroTag: "callBtn",
                onPressed: () async {
                  final userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.user.id)
                      .get();
                  final phoneNumber = userDoc.data()?['phonenumber'];
                  if (phoneNumber != null && phoneNumber.isNotEmpty) {
                    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
                    await launchUrl(launchUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No phone number available"),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.phone),
                label: const Text('CALL'),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.2),
            // Comments button with full functionality
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: FloatingActionButton.extended(
                heroTag: "commentBtn",
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    builder: (context) {
                      return SafeArea(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  "Comments",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.user.id)
                                        .collection('comments')
                                        .orderBy('createdAt', descending: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return const Center(
                                          child: Text("No comments yet"),
                                        );
                                      }

                                      final comments = snapshot.data!.docs;

                                      return ListView.builder(
                                        itemCount: comments.length,
                                        itemBuilder: (context, index) {
                                          final data =
                                              comments[index].data()
                                                  as Map<String, dynamic>;
                                          final Timestamp? ts =
                                              data['createdAt'];
                                          String formattedDate = '';
                                          if (ts != null) {
                                            DateTime dt = ts.toDate();
                                            formattedDate = DateFormat(
                                              'dd/MM/yyyy HH:mm',
                                            ).format(dt);
                                          }
                                          return Column(
                                            children: [
                                              ListTile(
                                                leading:
                                                    (data['img'] != null &&
                                                        data['img'].isNotEmpty)
                                                    ? CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(
                                                              data['img'],
                                                            ),
                                                      )
                                                    : const CircleAvatar(
                                                        child: Icon(
                                                          Icons.person,
                                                        ),
                                                      ),
                                                title: Row(
                                                  children: [
                                                    Text(data['commenterName']),
                                                    const Spacer(),
                                                    Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Text(
                                                  data['text'] ?? '',
                                                ),
                                              ),
                                              const Divider(thickness: 1),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Form(
                                        key: formstate,
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return "Please enter a comment";
                                            }
                                            return null;
                                          },
                                          controller: comment,
                                          decoration: InputDecoration(
                                            hintText: "Add a comment...",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (formstate.currentState!
                                            .validate()) {
                                          final userId = widget.user.id;
                                          final currentUser = FirebaseAuth
                                              .instance
                                              .currentUser!;
                                          final userDoc =
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(currentUser.uid)
                                                  .get();
                                          final userImg =
                                              userDoc.data()?['img'] ?? '';

                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userId)
                                              .collection('comments')
                                              .add({
                                                'text': comment.text.trim(),
                                                'commenterId': currentUser.uid,
                                                'commenterName':
                                                    currentUser.email
                                                        ?.split('@')
                                                        .first ??
                                                    'Anonymous',
                                                'createdAt':
                                                    FieldValue.serverTimestamp(),
                                                'img': userImg,
                                              });

                                          comment.clear();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Comment submitted",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Icon(Icons.send),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.messenger_outline),
                label: const Text('COMMENTS'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
