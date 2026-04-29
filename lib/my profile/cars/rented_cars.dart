import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/my%20profile/cars/edit_vehicle.dart';
import 'package:rentme/my%20profile/my_profile.dart';

class RentedCars extends StatefulWidget {
  const RentedCars({super.key});

  @override
  State<RentedCars> createState() => _RentedCarsState();
}

class _RentedCarsState extends State<RentedCars> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('cars')
                  .where('status', isEqualTo: 'Rented')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No rented vehicles",
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

  Widget buildCarCard(Map<String, dynamic> car) {
    final pricePerDay = int.tryParse(car['price'].toString()) ?? 0;
    final rentedAt = (car['rentedAt'] as Timestamp?)?.toDate();
    final endTime = (car['endTime'] as Timestamp?)?.toDate();

    int rentedDays = 0;
    int totalPrice = 0;

    if (rentedAt != null && endTime != null) {
      rentedDays = endTime.difference(rentedAt).inDays;
      totalPrice = rentedDays * pricePerDay;
    }
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
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Car Options"),
                  content: const Text("Choose an action for this car:"),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        // Child dialog (summary)
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text("Rental Summary"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Car: ${car['vehiclefullname']}"),
                                const SizedBox(height: 8),
                                Text("Rented for: $rentedDays day(s)"),
                                const SizedBox(height: 8),
                                Text("Total Price: $totalPrice DA"),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                        )
                                        .collection('cars')
                                        .doc(car['id'])
                                        .update({
                                          'status': 'Available',
                                          'rentedAt': null,
                                          'endTime': null,
                                        });

                                    await FirebaseFirestore.instance
                                        .collection('cars')
                                        .doc(car['id'])
                                        .update({
                                          'status': 'Available',
                                          'rentedAt': null,
                                          'endTime': null,
                                        });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Car marked as available",
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e")),
                                    );
                                  }

                                  // Close both dialogs safely
                                  Navigator.pop(dialogContext); // close summary
                                  Navigator.pop(context); // close parent
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("Make Available"),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // close parent first
                        final TextEditingController daysController =
                            TextEditingController();
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text("Prolong Rent"),
                            content: TextField(
                              controller: daysController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Enter extra days",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final extraDays =
                                      int.tryParse(
                                        daysController.text.trim(),
                                      ) ??
                                      0;
                                  if (extraDays > 0) {
                                    try {
                                      final newEndTime =
                                          (car['endTime'] as Timestamp)
                                              .toDate()
                                              .add(Duration(days: extraDays));

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          )
                                          .collection('cars')
                                          .doc(car['id'])
                                          .update({
                                            'status': 'Rented',
                                            'endTime': newEndTime,
                                          });

                                      await FirebaseFirestore.instance
                                          .collection('cars')
                                          .doc(car['id'])
                                          .update({
                                            'status': 'Rented',
                                            'endTime': newEndTime,
                                          });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Rent prolonged by $extraDays days",
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  }
                                  Navigator.pop(dialogContext); // close summary
                                  Navigator.pop(context); // close parent
                                },
                                child: const Text("Confirm"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("Prolong Rent"),
                    ),
                  ],
                ),
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
                        Row(
                          children: [
                            Text(car['price'] ?? ''),
                            const Spacer(),
                            Text(
                              "Total: $totalPrice DA",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            if (car['endTime'] != null)
                              CountdownTimer(
                                endTime: (car['endTime'] as Timestamp).toDate(),
                                carId: car['id'],
                              )
                            else
                              const Text("No rental time set"),
                          ],
                        ),
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

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final String carId;

  const CountdownTimer({super.key, required this.endTime, required this.carId});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remaining = widget.endTime.difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        remaining = widget.endTime.difference(DateTime.now());
      });

      if (remaining.isNegative) {
        timer.cancel();

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('cars')
              .doc(widget.carId)
              .update({
                'status': 'Available',
                'rentedAt': null,
                'endTime': null,
              });

          await FirebaseFirestore.instance
              .collection('cars')
              .doc(widget.carId)
              .update({
                'status': 'Available',
                'rentedAt': null,
                'endTime': null,
              });
        } catch (e) {
          debugPrint("Error updating car availability: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return Text(
      "$days d $hours h $minutes m $seconds s left",
      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    );
  }
}
