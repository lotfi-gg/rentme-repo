import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/my profile/cars/edit_vehicle.dart';

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
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: SizedBox(
          width: double.infinity,
          child: Card(
            color: const Color(0xFF1E1E1E),
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

                final cars = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                // Sort expired first
                cars.sort((a, b) {
                  DateTime? endA = (a['endTime'] as Timestamp?)?.toDate();
                  DateTime? endB = (b['endTime'] as Timestamp?)?.toDate();

                  bool expiredA = endA != null && endA.isBefore(DateTime.now());
                  bool expiredB = endB != null && endB.isBefore(DateTime.now());

                  if (expiredA && !expiredB) return -1;
                  if (!expiredA && expiredB) return 1;
                  return 0;
                });

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return buildCarCard(car);
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
    final priceValue = car['price'];
    final pricePerDay = (priceValue is int)
        ? priceValue
        : (priceValue is double ? priceValue.toInt() : 0);

    final rentedAt = (car['rentedAt'] as Timestamp?)?.toDate();
    final endTime = (car['endTime'] as Timestamp?)?.toDate();

    int rentedDays = 0;
    int totalPrice = 0;

    if (rentedAt != null) {
      final now = DateTime.now();
      final effectiveEnd = endTime ?? now;
      rentedDays = effectiveEnd.difference(rentedAt).inDays;
      if (rentedDays <= 0) rentedDays = 1; // minimum 1 day
      totalPrice = rentedDays * pricePerDay;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 150,
        child: Card(
          color: const Color(0xFF1E1E1E),
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
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    "Car Options",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text(
                    "Choose an action for this car:",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    // Make Available
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E1E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              "Rental Summary",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Car: ${car['vehiclefullname']}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (_) {
                                    final rentedAt =
                                        (car['rentedAt'] as Timestamp?)
                                            ?.toDate();
                                    final priceValue = car['price'];
                                    final pricePerDay = (priceValue is int)
                                        ? priceValue
                                        : (priceValue is double
                                              ? priceValue.toInt()
                                              : 0);

                                    int elapsedDays = 0;
                                    int dynamicTotal = 0;

                                    if (rentedAt != null) {
                                      elapsedDays = DateTime.now()
                                          .difference(rentedAt)
                                          .inDays;
                                      if (elapsedDays <= 0)
                                        elapsedDays = 1; // minimum 1 day
                                      dynamicTotal = elapsedDays * pricePerDay;
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Rented for: $elapsedDays day(s)",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Amount to pay: $dynamicTotal ${car['currency'] ?? ''}",
                                          style: const TextStyle(
                                            color: Colors.deepOrangeAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrangeAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    final rentedAt =
                                        (car['rentedAt'] as Timestamp?)
                                            ?.toDate();
                                    final priceValue = car['price'];
                                    final pricePerDay = (priceValue is int)
                                        ? priceValue
                                        : (priceValue is double
                                              ? priceValue.toInt()
                                              : 0);

                                    int elapsedDays = 0;
                                    int totalPrice = 0;

                                    if (rentedAt != null) {
                                      elapsedDays = DateTime.now()
                                          .difference(rentedAt)
                                          .inDays;
                                      if (elapsedDays <= 0)
                                        elapsedDays = 1; // minimum 1 day
                                      totalPrice = elapsedDays * pricePerDay;
                                    }

                                    // ✅ Show the calculated total before making available
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Rental ended early. Total price: $totalPrice ${car['currency'] ?? ''}",
                                        ),
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                    );

                                    // ✅ Update Firestore to make car available again
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

                                    if (!mounted) return;
                                    Navigator.pop(dialogContext);

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Car is now available again.",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },

                                child: const Text(
                                  "Confirm",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        "Make Available",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    // Prolong Rent
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final TextEditingController daysController =
                            TextEditingController();
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E1E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              "Prolong Rent",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: TextField(
                              controller: daysController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Enter extra days",
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrangeAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final extraDays = int.tryParse(
                                    daysController.text,
                                  );
                                  if (extraDays == null || extraDays <= 0) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please enter a valid number of days",
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    final currentEndTime =
                                        (car['endTime'] as Timestamp?)
                                            ?.toDate() ??
                                        DateTime.now();
                                    final newEndTime = currentEndTime.add(
                                      Duration(days: extraDays),
                                    );

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
                                        .update({'endTime': newEndTime});

                                    await FirebaseFirestore.instance
                                        .collection('cars')
                                        .doc(car['id'])
                                        .update({'endTime': newEndTime});

                                    if (!mounted) return;
                                    Navigator.of(dialogContext).pop();

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Rental prolonged by $extraDays day(s)",
                                        ),
                                        backgroundColor:
                                            Colors.greenAccent.shade700,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: $e"),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Confirm",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        "Prolong Rent",
                        style: TextStyle(color: Colors.white),
                      ),
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
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                  child: car['img'] != null && car['img'] != ''
                      ? Image.network(
                          car['img'],
                          height: double.infinity,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'images/car.png',
                          height: double.infinity,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car['vehiclefullname'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Year: ${car['year'] ?? ''}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Transmission: ${car['transmission'] ?? ''}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Total : $totalPrice ${car['currency'] ?? ''}",
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Spacer(),
                            if (car['endTime'] != null)
                              CountdownTimer(
                                endTime: (car['endTime'] as Timestamp).toDate(),
                                carId: car['id'],
                              )
                            else
                              const Text(
                                "No rental time set",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
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
    _startTimer(widget.endTime);
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.endTime != oldWidget.endTime) {
      _timer?.cancel();
      _startTimer(widget.endTime);
    }
  }

  void _startTimer(DateTime endTime) {
    remaining = endTime.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        remaining = endTime.difference(DateTime.now());
      });
      if (remaining.isNegative) {
        timer.cancel();
        setState(() {}); // rebuild to show "Available"
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
    if (remaining.isNegative) {
      return const Text(
        "Available",
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }

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
