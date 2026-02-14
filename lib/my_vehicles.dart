import 'package:flutter/material.dart';
import 'package:rentme/add_vehicle.dart';
import 'package:rentme/edit_vehicle.dart';

class MyVehicles extends StatefulWidget {
  const MyVehicles({super.key});

  @override
  State<MyVehicles> createState() => _MyVehiclesState();
}

class _MyVehiclesState extends State<MyVehicles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        width: 150,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddVehicle()),
            );
          },
          icon: Icon(Icons.add),
          label: Text('ADD VEHICLE'),
        ),
      ),

      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(radius: 70, child: Image.asset('images/user logo.png')),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    height: 150,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditVehicle(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              child: Image.asset(
                                'images/image1.jpg',
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
                                children: const [
                                  Text('vehicle full name'),
                                  Text('year'),
                                  Text('transmission'),
                                  Row(
                                    children: [
                                      SizedBox(),
                                      Spacer(),
                                      Text('rented'),
                                      SizedBox(width: 15),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(),
                                      Spacer(),
                                      Text('time'),
                                      SizedBox(width: 15),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
