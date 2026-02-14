import 'package:flutter/material.dart';
import 'package:rentme/my_vehicles.dart';
import 'package:rentme/add_vehicle.dart';
import 'package:rentme/home_page.dart';
import 'package:rentme/public_profile.dart';
import 'package:rentme/welcome_page.dart';

void main() async {
  runApp(RentMe());
}

class RentMe extends StatefulWidget {
  const RentMe({super.key});

  @override
  State<RentMe> createState() => _RentMeState();
}

class _RentMeState extends State<RentMe> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}
