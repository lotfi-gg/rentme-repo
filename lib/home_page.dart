import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/create_page.dart';
import 'package:rentme/models/user_model.dart';
import 'package:rentme/my_profile.dart';
import 'package:rentme/public_profile.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:rentme/search_by_car.dart';
import 'package:rentme/search_by_location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool randomMode = true;
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: FloatingActionButton.extended(
              heroTag: "nearbyBtn",
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(30),
              ),
              onPressed: () {
                setState(() {
                  randomMode = !randomMode; // toggle mode
                });
              },
              icon: randomMode
                  ? const Icon(Icons.near_me)
                  : const Icon(Icons.ac_unit),
              label: randomMode ? const Text('Nearby') : const Text('Random'),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),

          (me?.isFirstTime ?? true)
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: FloatingActionButton.extended(
                    heroTag: "createBtn",
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(30),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.car_rental_sharp),
                    label: const Text('CREATE'),
                  ),
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: SpeedDial(
                    heroTag: "searchBtn",
                    icon: Icons.search, // main icon
                    label: const Text('Search By'),
                    activeIcon: Icons.close, // icon when expanded
                    spacing: 10,
                    overlayColor: Colors.black,
                    overlayOpacity: 0.3,
                    children: [
                      SpeedDialChild(
                        child: const Icon(Icons.location_on),
                        label: 'Search by Location',
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
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // 🔹 Country dropdown
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('users')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData)
                                              return const CircularProgressIndicator();
                                            final countries = snapshot
                                                .data!
                                                .docs
                                                .map(
                                                  (doc) =>
                                                      doc['country']
                                                          ?.toString() ??
                                                      '',
                                                )
                                                .where((c) => c.isNotEmpty)
                                                .toSet()
                                                .toList();

                                            return DropdownButtonFormField<
                                              String
                                            >(
                                              decoration: const InputDecoration(
                                                labelText: "Country",
                                              ),
                                              value: selectedCountry,
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

                                        // 🔹 Province dropdown (filtered by country)
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
                                              if (!snapshot.hasData)
                                                return const CircularProgressIndicator();
                                              final provinces = snapshot
                                                  .data!
                                                  .docs
                                                  .map(
                                                    (doc) =>
                                                        doc['province']
                                                            ?.toString() ??
                                                        '',
                                                  )
                                                  .where((p) => p.isNotEmpty)
                                                  .toSet()
                                                  .toList();

                                              return DropdownButtonFormField<
                                                String
                                              >(
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: "Province",
                                                    ),
                                                value: selectedProvince,
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

                                        // 🔹 Townhall dropdown (filtered by province)
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
                                              if (!snapshot.hasData)
                                                return const CircularProgressIndicator();
                                              final townhalls = snapshot
                                                  .data!
                                                  .docs
                                                  .map(
                                                    (doc) =>
                                                        doc['townhall']
                                                            ?.toString() ??
                                                        '',
                                                  )
                                                  .where((t) => t.isNotEmpty)
                                                  .toSet()
                                                  .toList();

                                              return DropdownButtonFormField<
                                                String
                                              >(
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: "Townhall",
                                                    ),
                                                value: selectedTownhall,
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
                                                builder: (_) =>
                                                    SearchResultsPage(
                                                      country: selectedCountry,
                                                      province:
                                                          selectedProvince,
                                                      townhall:
                                                          selectedTownhall,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: const Text("Search"),
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
                        child: const Icon(Icons.directions_car),
                        label: 'Search by Car',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchByCar(),
                            ),
                          );
                          // TODO: implement search by car logic
                          print("Search by Car clicked");
                        },
                      ),
                    ],
                  ),
                ),
        ],
      ),
      appBar: AppBar(
        actions: [
          const SizedBox(width: 12),
          IconButton(
            onPressed: () async {
              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.signOut();
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('auth', (route) => false);
              print('user signed out');
            },
            icon: const Icon(Iconsax.logout),
            iconSize: 25,
          ),
          const Spacer(),
          (me?.isFirstTime ?? true)
              ? const SizedBox()
              : InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyProfile()),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 23,
                    backgroundImage: AssetImage('images/user logo.png'),
                  ),
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

          final users = snapshot.data!.docs
              .map(
                (doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

          final nearbyUsers = users.where((user) {
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

          // ✅ FIX: Only show "No nearby agencies" when in nearby mode
          if (!randomMode && nearbyUsers.isEmpty) {
            return const Center(child: Text("No nearby agencies within 10 km"));
          }

          return randomMode
              ? RefreshIndicator(
                  onRefresh: () async {
                    setState(() {}); // triggers rebuild
                  },
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      // 🔑 Shuffle users before displaying
                      final shuffledUsers = [...users]..shuffle();
                      final user = shuffledUsers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          height: 130,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
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
                                      topLeft: Radius.circular(25),
                                      bottomLeft: Radius.circular(25),
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
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user.agencyname ?? "No agency"),
                                        const SizedBox(height: 8),
                                        Text(
                                          "${user.province} / ${user.townhall}",
                                        ),
                                        const SizedBox(height: 8),
                                        const Text("Available Vehicles: 12345"),
                                      ],
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
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: user.img != null && user.img!.isNotEmpty
                            ? Image.network(
                                user.img!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.location_city),
                        title: Text(user.agencyname ?? "No agency"),
                        subtitle: Text(
                          "${user.province} / ${user.townhall}\n${dist.toStringAsFixed(2)} km away",
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
