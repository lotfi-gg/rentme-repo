import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/auth.dart';
import 'package:rentme/home/create_page.dart';
import 'package:rentme/models/user_model.dart';
import 'package:rentme/my profile/my_profile.dart';
import 'package:rentme/public profile/public_profile.dart';
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
  bool hasCreated = false;
  ChatUser? me;
  bool isLoading = true;

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
              hasCreated = doc.data()!.containsKey('hasCreated')
                  ? doc['hasCreated'] as bool
                  : false;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          if (isLoading)
            const SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(
                color: Colors.deepOrangeAccent,
                strokeWidth: 3,
              ),
            )
          else if (!hasCreated)
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
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set({'hasCreated': true}, SetOptions(merge: true));
                      setState(() {
                        hasCreated = true;
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
                    backgroundColor: const Color.fromARGB(255, 28, 28, 28),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFF1E1E1E),
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
                                          dropdownColor: const Color(
                                            0xFF2A2A2A,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: "Country",
                                            labelStyle: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFF2A2A2A),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          value: selectedCountry,
                                          items: countries
                                              .map(
                                                (c) => DropdownMenuItem(
                                                  value: c,
                                                  child: Text(
                                                    c,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
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
                                            dropdownColor: const Color(
                                              0xFF2A2A2A,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: "Province",
                                              labelStyle: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                              filled: true,
                                              fillColor: const Color(
                                                0xFF2A2A2A,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            value: selectedProvince,
                                            items: provinces
                                                .map(
                                                  (p) => DropdownMenuItem(
                                                    value: p,
                                                    child: Text(
                                                      p,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
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
                                            dropdownColor: const Color(
                                              0xFF2A2A2A,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: "Townhall",
                                              labelStyle: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                              filled: true,
                                              fillColor: const Color(
                                                0xFF2A2A2A,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            value: selectedTownhall,
                                            items: townhalls
                                                .map(
                                                  (t) => DropdownMenuItem(
                                                    value: t,
                                                    child: Text(
                                                      t,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
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
                    backgroundColor: const Color.fromARGB(255, 28, 28, 28),
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Auth()),
                (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Iconsax.logout, color: Colors.deepOrangeAccent),
            iconSize: 25,
          ),
          const Spacer(),
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
                      onTap: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.deepOrangeAccent,
                              ),
                            );
                          },
                        );
                        await Future.delayed(const Duration(milliseconds: 500));
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyProfile(),
                          ),
                        );
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 23,
                        backgroundImage:
                            (chatUser.img != null && chatUser.img!.isNotEmpty)
                            ? NetworkImage(chatUser.img!)
                            : const AssetImage('images/user logo.png')
                                  as ImageProvider,
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
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final users = snapshot.data!.docs
              .map(
                (doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

          final Map<String, ChatUser> userMap = {};
          for (var u in users) {
            if (u.id != null) {
              userMap[u.id!] = u;
            }
          }
          final uniqueUsers = userMap.values.toList();
          uniqueUsers.shuffle();

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
            return dist < 15;
          }).toList();

          final displayUsers = randomMode ? uniqueUsers : nearbyUsers;

          return ListView.builder(
            itemCount: displayUsers.length,
            itemBuilder: (context, index) {
              final user = displayUsers[index];
              return Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: user.img != null && user.img!.isNotEmpty
                            ? Image.network(
                                user.img!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade800,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.agencyname ?? "No agency",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${user.country ?? ''} • ${user.province ?? ''} • ${user.townhall ?? ''}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // ✅ Distance display
                            if (me != null &&
                                me!.latitude != null &&
                                me!.longitude != null &&
                                user.latitude != null &&
                                user.longitude != null)
                              Text(
                                "${calculateDistance(me!.latitude!, me!.longitude!, user.latitude!, user.longitude!).toStringAsFixed(1)} km away",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueAccent,
                                ),
                              ),

                            const SizedBox(height: 6),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.id)
                                  .collection('cars')
                                  .where('status', isEqualTo: 'Available')
                                  .snapshots(),
                              builder: (context, carSnapshot) {
                                if (!carSnapshot.hasData)
                                  return const SizedBox();
                                final count = carSnapshot.data!.docs.length;
                                return Text(
                                  count == 0
                                      ? "No available vehicles"
                                      : "Available Vehicles: $count",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: count == 0
                                        ? Colors.redAccent
                                        : Colors.greenAccent,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.deepOrangeAccent,
                        size: 18,
                      ),
                    ],
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
