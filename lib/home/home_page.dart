import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/home/create_page.dart';
import 'package:rentme/models/user_model.dart';
import 'package:rentme/my%20profile/my_profile.dart';
import 'package:rentme/public%20profile/public_profile.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:rentme/home/search_by_car.dart';
import 'package:rentme/home/search_results.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool randomMode = true;
  bool hasCreated = false; // ✅ track if user already created
  ChatUser? me;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) {
          if (doc.exists) {
            setState(() {
              me = ChatUser.fromJson(doc.data()!);
              // ✅ check if user hasCreated flag exists
              hasCreated = doc.data()!.containsKey('hasCreated')
                  ? doc['hasCreated'] as bool
                  : false;
            });
          }
        });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // pi/180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // distance in km
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nearby / Random toggle
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: FloatingActionButton.extended(
              heroTag: "nearbyBtn",
              backgroundColor: randomMode
                  ? Colors.blueAccent
                  : Colors.deepOrangeAccent,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () {
                setState(() {
                  randomMode = !randomMode;
                });
              },
              icon: randomMode
                  ? const Icon(Icons.near_me)
                  : const Icon(Icons.shuffle),
              label: Text(
                randomMode ? 'Nearby' : 'Random',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.2),

          // ✅ Only show CREATE if user has not created yet
          if (!hasCreated)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: FloatingActionButton.extended(
                heroTag: "createBtn",
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatePage()),
                  ).then((result) {
                    if (result == true) {
                      // ✅ Only mark created if CreatePage returned success
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set({'hasCreated': true}, SetOptions(merge: true));

                      setState(() {
                        hasCreated =
                            true; // ✅ hides the CREATE button immediately
                      });
                    }
                  });
                },

                icon: const Icon(Icons.car_rental_sharp),
                label: const Text(
                  'CREATE',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            )
          else
            // ✅ Show Search options instead
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: SpeedDial(
                heroTag: "searchBtn",
                icon: Icons.search,
                activeIcon: Icons.close,
                label: const Text(
                  'Search By',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                spacing: 10,
                overlayColor: Colors.black,
                overlayOpacity: 0.3,
                children: [
                  SpeedDialChild(
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.deepOrangeAccent,
                    ),
                    label: 'Search by Location',
                    backgroundColor: const Color(0xFF1E1E1E),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          String? selectedCountry;
                          String? selectedProvince;
                          String? selectedTownhall;

                          return StatefulBuilder(
                            builder: (context, setModalState) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Search by Location",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Country dropdown
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        }
                                        final countries = snapshot.data!.docs
                                            .map((doc) {
                                              final data =
                                                  doc.data()
                                                      as Map<String, dynamic>;
                                              return data['country']
                                                      ?.toString() ??
                                                  '';
                                            })
                                            .where((c) => c.isNotEmpty)
                                            .toSet()
                                            .toList();

                                        return DropdownButtonFormField<String>(
                                          decoration: const InputDecoration(
                                            labelText: "Country",
                                          ),
                                          initialValue: selectedCountry,
                                          items: countries
                                              .map(
                                                (c) => DropdownMenuItem(
                                                  value: c,
                                                  child: Text(c),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            setModalState(() {
                                              selectedCountry = val;
                                              selectedProvince = null;
                                              selectedTownhall = null;
                                            });
                                          },
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    // Province dropdown
                                    if (selectedCountry != null)
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .where(
                                              'country',
                                              isEqualTo: selectedCountry,
                                            )
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const CircularProgressIndicator();
                                          }
                                          final provinces = snapshot.data!.docs
                                              .map((doc) {
                                                final data =
                                                    doc.data()
                                                        as Map<String, dynamic>;
                                                return data['province']
                                                        ?.toString() ??
                                                    '';
                                              })
                                              .where((p) => p.isNotEmpty)
                                              .toSet()
                                              .toList();

                                          return DropdownButtonFormField<
                                            String
                                          >(
                                            decoration: const InputDecoration(
                                              labelText: "Province",
                                            ),
                                            initialValue: selectedProvince,
                                            items: provinces
                                                .map(
                                                  (p) => DropdownMenuItem(
                                                    value: p,
                                                    child: Text(p),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) {
                                              setModalState(() {
                                                selectedProvince = val;
                                                selectedTownhall = null;
                                              });
                                            },
                                          );
                                        },
                                      ),

                                    const SizedBox(height: 12),

                                    // Townhall dropdown
                                    if (selectedProvince != null)
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .where(
                                              'country',
                                              isEqualTo: selectedCountry,
                                            )
                                            .where(
                                              'province',
                                              isEqualTo: selectedProvince,
                                            )
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const CircularProgressIndicator();
                                          }
                                          final townhalls = snapshot.data!.docs
                                              .map((doc) {
                                                final data =
                                                    doc.data()
                                                        as Map<String, dynamic>;
                                                return data['townhall']
                                                        ?.toString() ??
                                                    '';
                                              })
                                              .where((t) => t.isNotEmpty)
                                              .toSet()
                                              .toList();

                                          return DropdownButtonFormField<
                                            String
                                          >(
                                            decoration: const InputDecoration(
                                              labelText: "Townhall",
                                            ),
                                            initialValue: selectedTownhall,
                                            items: townhalls
                                                .map(
                                                  (t) => DropdownMenuItem(
                                                    value: t,
                                                    child: Text(t),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) {
                                              setModalState(() {
                                                selectedTownhall = val;
                                              });
                                            },
                                          );
                                        },
                                      ),

                                    const SizedBox(height: 20),

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SearchResults(
                                              country: selectedCountry,
                                              province: selectedProvince,
                                              townhall: selectedTownhall,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.deepOrangeAccent,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          double.infinity,
                                          48,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "SEARCH",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  SpeedDialChild(
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.blueAccent,
                    ),
                    label: 'Search by Car',
                    backgroundColor: const Color(0xFF1E1E1E),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchByCar(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        actions: [
          IconButton(
            onPressed: () async {
              GoogleSignIn googleSignIn = GoogleSignIn();
              await googleSignIn.signOut();
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('auth', (route) => false);
            },
            icon: const Icon(Iconsax.logout, color: Colors.deepOrangeAccent),
            iconSize: 25,
          ),
          const Spacer(),

          // ✅ Listen to Firestore for current user
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const SizedBox();
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final chatUser = ChatUser.fromJson(userData);

              return (chatUser.isFirstTime ?? true)
                  ? const SizedBox()
                  : InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyProfile(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 23,
                        backgroundImage: AssetImage('images/user logo.png'),
                      ),
                    );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(
              FieldPath.documentId,
              isNotEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          // ✅ Build users list
          final users = snapshot.data!.docs
              .map(
                (doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

          // ✅ Remove duplicates safely (skip null ids)
          final Map<String, ChatUser> userMap = {};
          for (var u in users) {
            if (u.id != null) {
              userMap[u.id!] = u;
            }
          }
          final uniqueUsers = userMap.values.toList();

          // ✅ Shuffle once
          uniqueUsers.shuffle();

          // ✅ Nearby users also deduplicated
          final nearbyUsers = uniqueUsers.where((user) {
            if (me == null || me!.latitude == null || me!.longitude == null) {
              return false;
            }
            if (user.latitude == null || user.longitude == null) return false;

            final dist = calculateDistance(
              me!.latitude!,
              me!.longitude!,
              user.latitude!,
              user.longitude!,
            );
            return dist < 15; // threshold in km
          }).toList();

          if (!randomMode && nearbyUsers.isEmpty) {
            return const Center(child: Text("No nearby agencies within 15 km"));
          }

          return randomMode
              ? RefreshIndicator(
                  onRefresh: () async {
                    setState(() {}); // triggers rebuild
                  },
                  child: ListView.builder(
                    itemCount: uniqueUsers.length,
                    itemBuilder: (context, index) {
                      final user = uniqueUsers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          height: 130,
                          child: Card(
                            color: const Color(
                              0xFF1E1E1E,
                            ), // ✅ fond premium anthracite
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              splashColor:
                                  Colors.transparent, // ✅ pas d’effet splash
                              highlightColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PublicProfile(user: user),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    child:
                                        user.img != null && user.img!.isNotEmpty
                                        ? Image.network(
                                            user.img!,
                                            height: double.infinity,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'images/user logo.png',
                                            height: double.infinity,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            user.agencyname ?? "No agency",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .white, // ✅ contraste fort
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "${user.province ?? ''} / ${user.townhall ?? ''}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors
                                                  .grey, // ✅ texte secondaire
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(user.id)
                                                .collection('cars')
                                                .where(
                                                  'status',
                                                  isEqualTo: 'Available',
                                                )
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return const SizedBox();
                                              }
                                              final count =
                                                  snapshot.data!.docs.length;
                                              return Text(
                                                count == 0
                                                    ? "No available vehicles"
                                                    : "Available Vehicles: $count",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors
                                                      .green, // ✅ accent premium
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : ListView.builder(
                  itemCount: nearbyUsers.length,
                  itemBuilder: (context, index) {
                    final user = nearbyUsers[index];
                    final dist = calculateDistance(
                      me!.latitude!,
                      me!.longitude!,
                      user.latitude!,
                      user.longitude!,
                    );

                    return Card(
                      color: const Color(
                        0xFF1E1E1E,
                      ), // ✅ fond anthracite premium
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4, // ✅ ombre subtile
                      margin: const EdgeInsets.all(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.transparent, // ✅ pas d’effet splash
                        highlightColor:
                            Colors.transparent, // ✅ pas d’effet highlight
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfile(user: user),
                            ),
                          );
                        },
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
                                : Image.asset(
                                    'images/user logo.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          title: Text(
                            user.agencyname ?? "No agency",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // ✅ contraste fort
                            ),
                          ),
                          subtitle: Text(
                            "${user.province ?? ''} / ${user.townhall ?? ''}\n${dist.toStringAsFixed(2)} km away",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey, // ✅ texte secondaire
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.deepOrangeAccent, // ✅ accent premium
                            size: 18,
                          ),
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
