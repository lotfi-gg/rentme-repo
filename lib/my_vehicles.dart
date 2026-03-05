import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/avaiable_cars.dart';
import 'package:rentme/rented_cars.dart';

class MyVehicles extends StatefulWidget {
  const MyVehicles({super.key});

  @override
  State<MyVehicles> createState() => _MyVehiclesState();
}

class _MyVehiclesState extends State<MyVehicles> {
  PageController pageController = PageController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [];
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        children: [AvaiableCars(), RentedCars()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            currentIndex = value;
            pageController.jumpToPage(value);
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.messages),
            label: 'avaiable',
          ),
          NavigationDestination(icon: Icon(Iconsax.message), label: 'rented'),
        ],
      ),
    );
  }
}
