import 'package:flutter/material.dart';
import 'package:rentme/add_cars.dart';
import 'package:rentme/car_info.dart';
import 'package:rentme/create_page.dart';

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
    return MaterialApp(home: CarInfo());
  }
}
