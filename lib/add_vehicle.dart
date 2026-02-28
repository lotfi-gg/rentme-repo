import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentme/firebase/fire_auth.dart';
import 'package:rentme/firebase/fire_storage.dart';
import 'package:rentme/my_vehicles.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  TextEditingController vehiclefullname = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController transmission = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController status = TextEditingController();

  File? _selectedImage;
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: formstate,
              child: Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200,
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(
                                _selectedImage!,
                              ), // show picked image
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: AssetImage(
                                "images/car.jpg",
                              ), // fallback placeholder
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),

                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _pickImage();
                    },
                    child: Text('ADD PHOTO'),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: vehiclefullname,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Vehicle Full Name",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: year,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Year",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: "Transmission"),
                    items: ["Automatic", "Manual"].map((Transmission) {
                      return DropdownMenuItem<String>(
                        value: Transmission,
                        child: Text(Transmission),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        transmission.text = value ?? '';
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: price,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Price in Local Curancy",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () async {
                      if (formstate.currentState!.validate()) {
                        if (_selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Please add a photo before creating the car",
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          final user = FireCar.auth.currentUser!;
                          final carId = FireCar.firebaseFirestore
                              .collection('users')
                              .doc(user.uid)
                              .collection('cars')
                              .doc()
                              .id;

                          String imgUrl = '';
                          if (_selectedImage != null) {
                            // upload image first
                            imgUrl = await FireStorage().uploadCarImage(
                              _selectedImage!,
                              carId,
                            );
                          }

                          // only create car if upload succeeded
                          await FireCar.createCar(
                            carId,
                            vehiclefullname.text,
                            year.text,
                            transmission.text,
                            price.text,
                            imgUrl, // pass the URL string
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyVehicles(),
                            ),
                          );

                          print('Car created with image -----------');
                        } catch (e) {
                          print('Error while creating car ======> $e');
                        }
                      }
                    },
                    child: Text('ADD'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
