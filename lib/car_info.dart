import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CarInfo extends StatefulWidget {
  const CarInfo({super.key});

  @override
  State<CarInfo> createState() => _CarInfoState();
}

class _CarInfoState extends State<CarInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        child: Icon(Iconsax.add, size: 100),
                        height: 300,
                        width: double.infinity,
                      ),
                      Positioned(
                        bottom: -5,
                        right: -5,
                        child: IconButton.filled(
                          onPressed: () {},
                          icon: Icon(Iconsax.camera),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Full Name",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Phone Number",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Agency Name",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Country",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Province",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Town Hall",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(minimumSize: Size(250, 48)),
                  child: Text('SAVE AND CONTINUE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
