import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/add_vehicle.dart';
import 'package:rentme/edit_vehicle.dart';
import 'package:rentme/my_profile.dart';

class AvaiableCars extends StatefulWidget {
  const AvaiableCars({super.key});

  @override
  State<AvaiableCars> createState() => _AvaiableCarsState();
}

class _AvaiableCarsState extends State<AvaiableCars> {
  String name = ''; // holds the search text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: 150,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddVehicle()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('ADD VEHICLE'),
        ),
      ),
      appBar: AppBar(
        title: Card(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'search ..',
            ),
            onChanged: (value) {
              setState(() {
                // ✅ trim spaces and lowercase input
                name = value.trim().toLowerCase();
              });
            },
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyProfile()),
            );
          },
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
                  .where('avaiableIn', isEqualTo: 0) // rented cars
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No rented vehicles"));
                }

                final cars = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index].data() as Map<String, dynamic>;

                    // ✅ Always convert fields to string
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

                    // If search is empty, show all cars
                    if (name.isEmpty) {
                      return buildCarCard(car);
                    }

                    // ✅ Flexible search across multiple fields
                    if (nameAndYear.contains(name) ||
                        vehicleName.contains(name) ||
                        year.contains(name)) {
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
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onLongPress: () {
              final TextEditingController daysController =
                  TextEditingController();

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      "Rent Car",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Enter how many days you want to rent this car:",
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: daysController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Number of days",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // close dialog
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final days = daysController.text.trim();
                          if (days.isNotEmpty) {
                            try {
                              // ✅ Update Firestore: set avaiableIn to entered days
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('cars')
                                  .doc(car['id']) // car id from your document
                                  .update({
                                    'avaiableIn': int.parse(days),
                                    'rentedAt': FieldValue.serverTimestamp(),
                                    'status': 'Rented',
                                  });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Car rented for $days days"),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }

                            Navigator.pop(context); // close dialog after action
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
                            'images/car.jpg',
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
      ),
    );
  }
}
