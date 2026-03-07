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
  String search = ''; // holds the search text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: 150,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddVehicle()),
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
                search = value.trim().toLowerCase();
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
                  .where(
                    'avaiableIn',
                    isEqualTo: 0,
                  ) // ✅ only cars with avaiableIn = 0
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No available vehicles"));
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
                                  // 🔑 Update the car’s avaiableIn field
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(
                                        FirebaseAuth.instance.currentUser!.uid,
                                      )
                                      .collection('cars')
                                      .doc(car['id'])
                                      .update({
                                        'avaiableIn': selectedDays,
                                        'rentedAt': DateTime.now(),
                                      });

                                  // If you also keep a global cars collection:
                                  await FirebaseFirestore.instance
                                      .collection('cars')
                                      .doc(car['id'])
                                      .update({
                                        'avaiableIn': selectedDays,
                                        'rentedAt': DateTime.now(),
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
