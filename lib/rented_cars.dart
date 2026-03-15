import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/edit_vehicle.dart';
import 'package:rentme/my_profile.dart';

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
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('cars')
                  .where('avaiableIn', isNotEqualTo: 0)
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
                        final DateTime rentedAt = (car['rentedAt'] as Timestamp)
                            .toDate();
                        final DateTime now = DateTime.now();
                        final int rentedDays = now.difference(rentedAt).inDays;
                        final int pricePerDay =
                            int.tryParse(car['price'].toString()) ?? 0;
                        final int totalPrice = rentedDays * pricePerDay;

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
                                          'avaiableIn': 0,
                                          'status': 'Available',
                                          'rentedAt': null,
                                        });

                                    await FirebaseFirestore.instance
                                        .collection('cars')
                                        .doc(car['id'])
                                        .update({
                                          'avaiableIn': 0,
                                          'status': 'Available',
                                          'rentedAt': null,
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
                                      final newDays =
                                          (car['avaiableIn'] as int) +
                                          extraDays;

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
                                            'avaiableIn': newDays,
                                            'status': 'Rented',
                                          });

                                      await FirebaseFirestore.instance
                                          .collection('cars')
                                          .doc(car['id'])
                                          .update({
                                            'avaiableIn': newDays,
                                            'status': 'Rented',
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
                        Row(
                          children: [
                            Text(car['price'] ?? ''),
                            const Spacer(),
                            Text(
                              "Total: ${(int.tryParse(car['price'].toString()) ?? 0) * (car['avaiableIn'] as int)} DA",
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
                            if (car['rentedAt'] != null &&
                                car['avaiableIn'] != null)
                              CountdownTimer(
                                rentedAt: (car['rentedAt'] as Timestamp)
                                    .toDate(),
                                days: (car['avaiableIn'] as int),
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
  final DateTime rentedAt;
  final int days;
  final String carId;

  const CountdownTimer({
    super.key,
    required this.rentedAt,
    required this.days,
    required this.carId,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration remaining;
  late DateTime endTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // days should be treated as days, not seconds
    endTime = widget.rentedAt.add(Duration(days: widget.days));
    remaining = endTime.difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        remaining = endTime.difference(DateTime.now());
      });

      if (remaining.isNegative) {
        timer.cancel();

        // Update Firestore when countdown finishes
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('cars')
              .doc(widget.carId)
              .update({
                'avaiableIn': 0,
                'status': 'Available',
                'rentedAt': null,
              });

          await FirebaseFirestore.instance
              .collection('cars')
              .doc(widget.carId)
              .update({
                'avaiableIn': 0,
                'status': 'Available',
                'rentedAt': null,
              });
        } catch (e) {
          debugPrint("Error updating car availability: $e");
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If days change (rent prolonged), recalculate endTime
    if (oldWidget.days != widget.days) {
      endTime = widget.rentedAt.add(Duration(days: widget.days));
      remaining = endTime.difference(DateTime.now());
    }
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
