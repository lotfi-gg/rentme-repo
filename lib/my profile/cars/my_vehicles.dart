import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/my%20profile/cars/avaiable_cars.dart';
import 'package:rentme/my%20profile/cars/rented_cars.dart';
import 'package:rentme/my%20profile/my_profile.dart';

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
        leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.orange),
  onPressed: () async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrangeAccent,
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 200));

    // Close the loading dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Pop MyVehicles → return to MyProfile
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  },
),
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
          indicatorColor: Colors.deepOrangeAccent.withValues(alpha: 0.25),
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
