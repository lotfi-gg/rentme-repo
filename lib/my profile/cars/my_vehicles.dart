import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/my%20profile/cars/avaiable_cars.dart';
import 'package:rentme/my%20profile/cars/rented_cars.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // ✅ dark anthracite background
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepOrangeAccent),
        title: const Text(
          "My Vehicles",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        children: const [AvaiableCars(), RentedCars()],
      ),

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E), // ✅ dark bar
          indicatorColor: Colors.deepOrangeAccent.withOpacity(0.25),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Colors.deepOrangeAccent,
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(color: Colors.white70);
          }),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.deepOrangeAccent);
            }
            return const IconThemeData(color: Colors.white70);
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (value) {
            setState(() {
              currentIndex = value;
              pageController.jumpToPage(value);
            });
          },
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.car), label: 'Available'),
            NavigationDestination(icon: Icon(Iconsax.car5), label: 'Rented'),
          ],
        ),
      ),
    );
  }
}
