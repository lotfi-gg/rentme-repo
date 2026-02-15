import 'package:flutter/material.dart';

class EditVehicle extends StatefulWidget {
  const EditVehicle({super.key});

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

class _EditVehicleState extends State<EditVehicle> {
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
                  height: 200,
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
                ElevatedButton(onPressed: () {}, child: Text('EDIT PHOTO')),
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
                  items: ["Automatic", "Manual"].map((transmission) {
                    return DropdownMenuItem<String>(
                      value: transmission,
                      child: Text(transmission),
                    );
                  }).toList(),
                  onChanged: (value) {
                    print('-----Transmission-----> $value');
                  },
                ),
                SizedBox(height: 30),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Status"),
                  items: ["Avaiable", "Rented"].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    print('-----Status-----> $value');
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
                  child: Text('SAVE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
