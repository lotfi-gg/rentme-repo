import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/add_vehicle.dart';
import 'package:rentme/edit_vehicle.dart';
import 'package:rentme/my_profile.dart';

class RentedCars extends StatefulWidget {
  const RentedCars({super.key});

  @override
  State<RentedCars> createState() => _RentedCarsState();
}

class _RentedCarsState extends State<RentedCars> {
  String name = ''; // holds the search text

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
                  .where('avaiableIn', isNotEqualTo: 0) // rented cars
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
  final String carId; // ✅ pass the car id so we can update Firestore

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
    endTime = widget.rentedAt.add(Duration(days: widget.days));
    remaining = endTime.difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;
      setState(() {
        remaining = endTime.difference(DateTime.now());
      });

      if (remaining.isNegative) {
        timer.cancel();

        // ✅ Update Firestore when countdown finishes
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('cars')
              .doc(widget.carId)
              .update({'avaiableIn': 0, 'status': 'Available'});
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

    return Text(
      "$days d $hours h left",
      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
    );
  }
}
