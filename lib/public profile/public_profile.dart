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

  @override
  void dispose() {
    pageController.dispose();
    comment.dispose();
    super.dispose();
  }

  void _showRatingDialog(BuildContext context) {
    int selectedStars = 0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E), // ✅ dark theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // ✅ smooth corners
          ),
          title: const Text(
            "Rate this service",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStars = index + 1;
                      });
                    },
                    child: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36, // ✅ slightly larger for emphasis
                    ),
                  );
                }),
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[300], // ✅ cancel button style
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent, // ✅ accent color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
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
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1E1E1E),
                      content: Text(
                        "Thanks for rating $selectedStars star(s)!",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Submit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Ratings section always visible
  Widget _buildRatingsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .collection('ratings')
          .snapshots(),
      builder: (context, snapshot) {
        int ratingCount = 0;
        double avgRating = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final ratings = snapshot.data!.docs
              .map(
                (doc) => (doc.data() as Map<String, dynamic>)['stars'] as int,
              )
              .toList();
          ratingCount = ratings.length;
          avgRating = ratings.reduce((a, b) => a + b) / ratingCount;
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => _showRatingDialog(context),
                  child: Icon(
                    index < avgRating.round() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              'Ratings : $ratingCount',
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepOrangeAccent),
        title: Text(
          widget.user.agencyname ?? "Profile",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButtons(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 50,
            child: Image.asset('images/user logo.png', height: 150),
          ),
          const SizedBox(height: 10),

          _buildRatingsSection(), // ✅ always visible

          const SizedBox(height: 10),

          NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              indicatorColor: Colors.deepOrangeAccent.withOpacity(0.25),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: Colors.deepOrangeAccent, // ✅ selected label color
                    fontWeight: FontWeight.bold,
                  );
                }
                return const TextStyle(
                  color: Colors.white70, // ✅ unselected label color
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: Colors.deepOrangeAccent);
                }
                return const IconThemeData(color: Colors.white70);
              }),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (value) {
                if (!mounted) return;
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
                NavigationDestination(
                  icon: Icon(Iconsax.car5),
                  label: 'Rented',
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              children: [
                PublicAvaiableCars(user: widget.user),
                PublicRentedCars(),
              ],
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
                backgroundColor: Colors.orangeAccent,
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
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Could not open location"),
                        ),
                      );
                    }
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No location available")),
                    );
                  }
                },
                child: const Icon(Icons.location_on, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Call & Comments buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.greenAccent,
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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.blueAccent,
                heroTag: "commentBtn",
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(
                      0xFF1E1E1E,
                    ), // ✅ dark anthracite background
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
                                    color: Colors.white, // ✅ white title
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // ✅ Comments list
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
                                          child: Text(
                                            "No comments yet",
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
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
                                                        backgroundColor: Colors
                                                            .deepOrangeAccent,
                                                        child: Icon(
                                                          Icons.person,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                title: Row(
                                                  children: [
                                                    Text(
                                                      data['commenterName'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
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
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.grey.shade800,
                                                thickness: 1,
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),

                                // ✅ Comment input
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "Add a comment...",
                                            hintStyle: const TextStyle(
                                              color: Colors.white54,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFF2A2A2A),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.deepOrangeAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(14),
                                      ),
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
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Color(
                                                0xFF1E1E1E,
                                              ),
                                              content: Text(
                                                "Comment submitted",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
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
                icon: const Icon(Icons.messenger_outline, color: Colors.white),
                label: const Text(
                  'COMMENTS',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
