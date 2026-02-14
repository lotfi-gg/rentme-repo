import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.red,
                    image: DecorationImage(
                      image: AssetImage("images/image1.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(onPressed: () {}, child: Text('ADD PHOTO')),
                SizedBox(height: 40),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Vehicle Full Name",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Year",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Transmission"),
                  items: ["Automatic", "Manual"].map((Transmission) {
                    return DropdownMenuItem<String>(
                      value: Transmission,
                      child: Text(Transmission),
                    );
                  }).toList(),
                  onChanged: (value) {
                    print('-----Transmission-----> $value');
                  },
                ),
                SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Price",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(minimumSize: Size(250, 48)),
                  child: Text('ADD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
