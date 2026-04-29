import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rentme/my%20profile/cars/add_vehicle.dart';
import 'package:rentme/my%20profile/cars/edit_vehicle.dart';
import 'package:rentme/my%20profile/my_profile.dart';

class AvaiableCars extends StatefulWidget {
  const AvaiableCars({super.key});

  @override
  State<AvaiableCars> createState() => _AvaiableCarsState();
}

class _AvaiableCarsState extends State<AvaiableCars> {
  String search = ''; // holds the search text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: SizedBox(
        width: 180, // ✅ slightly larger for importance
        child: FloatingActionButton.extended(
          heroTag: "addVehicleBtn",
          backgroundColor: Colors.deepOrangeAccent, // ✅ premium accent color
          foregroundColor: Colors.white,
          elevation: 6, // ✅ subtle shadow for depth
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // ✅ smooth rounded corners
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddVehicle()),
            );
          },
          icon: const Icon(Icons.add, size: 22),
          label: const Text(
            'ADD VEHICLE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2, // ✅ spacing for premium look
            ),
          ),
        ),
      ),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF121212), // ✅ dark app bar
        elevation: 0,
        title: SizedBox(
          width: double.infinity, // ✅ full width search bar
          child: Card(
            color: const Color(0xFF1E1E1E), // ✅ dark anthracite background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white),
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  search = value.trim().toLowerCase();
                });
              },
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('cars')
                  .where('status', isEqualTo: 'Available')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No available vehicles",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final cars = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index].data() as Map<String, dynamic>;

                    final nameAndYear =
                        car['NameAndYear']?.toString().toLowerCase().trim() ??
                        '';
                    final vehicleName =
                        car['vehiclefullname']
                            ?.toString()
                            .toLowerCase()
                            .trim() ??
                        '';
                    final year =
                        car['year']?.toString().toLowerCase().trim() ?? '';

                    if (search.isEmpty ||
                        nameAndYear.contains(search) ||
                        vehicleName.contains(search) ||
                        year.contains(search)) {
                      return buildCarCard(car);
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build the car card UI
  Widget buildCarCard(Map<String, dynamic> car) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onLongPress: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      int? selectedDays;

                      return AlertDialog(
                        title: const Text("Rent Car"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "How many days do you want to rent this car?",
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Number of days",
                              ),
                              onChanged: (value) {
                                selectedDays = int.tryParse(value);
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (selectedDays != null && selectedDays! > 0) {
                                try {
                                  // 🔔 Vérifier et demander l'accès aux notifications
                                  FirebaseMessaging messaging =
                                      FirebaseMessaging.instance;
                                  NotificationSettings settings =
                                      await messaging.requestPermission();

                                  if (settings.authorizationStatus ==
                                      AuthorizationStatus.authorized) {
                                    String? token = await messaging.getToken();
                                    if (token != null) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          )
                                          .update({'fcmToken': token});
                                      print(
                                        "FCM Token enregistré:==========> $token",
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Notifications not allowed",
                                        ),
                                      ),
                                    );
                                    return; // ⚠️ Stop si pas de permission
                                  }

                                  // 🔑 Mise à jour du statut de la voiture
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(
                                        FirebaseAuth.instance.currentUser!.uid,
                                      )
                                      .collection('cars')
                                      .doc(car['id'])
                                      .update({
                                        'status': 'Rented',
                                        'rentedAt': DateTime.now(),
                                        'endTime': DateTime.now().add(
                                          Duration(seconds: selectedDays!),
                                        ),
                                      });

                                  await FirebaseFirestore.instance
                                      .collection('cars')
                                      .doc(car['id'])
                                      .update({
                                        'status': 'Rented',
                                        'rentedAt': DateTime.now(),
                                        'endTime': DateTime.now().add(
                                          Duration(seconds: selectedDays!),
                                        ),
                                      });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Car rented for $selectedDays day(s) successfully",
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Confirm"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditVehicle(carId: car['id']),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(25),
                        ),
                        child: car['img'] != null && car['img'] != ''
                            ? Image.network(
                                car['img'],
                                height: double.infinity,
                                width: 200,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'images/car.png',
                                height: double.infinity,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(car['vehiclefullname'] ?? ''),
                            const SizedBox(height: 6),
                            Text(car['year']?.toString() ?? ''),
                            const SizedBox(height: 6),
                            Text(car['transmission'] ?? ''),
                            const SizedBox(height: 6),
                            Text(car['price'] ?? ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ✅ Trash icon overlay
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Car"),
                      content: const Text(
                        "Are you sure you want to delete this car?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('cars')
                                  .doc(car['id'])
                                  .delete();

                              await FirebaseFirestore.instance
                                  .collection('cars')
                                  .doc(car['id'])
                                  .delete();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Car deleted successfully"),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                            Navigator.pop(context);
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
