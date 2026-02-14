import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/my_vehicles.dart';

class EditInfos extends StatefulWidget {
  const EditInfos({super.key});

  @override
  State<EditInfos> createState() => _EditInfosState();
}

class _EditInfosState extends State<EditInfos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('images/user logo.png'),
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: IconButton.filled(
                      onPressed: () {},
                      icon: Icon(Iconsax.edit),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyVehicles()),
                  );
                },
                style: ElevatedButton.styleFrom(minimumSize: Size(150, 48)),
                child: Text('MY VEHICLES'),
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
                style: ElevatedButton.styleFrom(minimumSize: Size(150, 48)),
                child: Text('SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
