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
  TextEditingController currancy = TextEditingController();

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
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage("images/car.jpg"),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('ADD PHOTO'),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: vehiclefullname,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "field required !"
                        : null,
                    decoration: const InputDecoration(
                      hintText: "Vehicle Full Name",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: year,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "field required !"
                        : null,
                    decoration: const InputDecoration(
                      hintText: "Year",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "field required !"
                        : null,
                    decoration: const InputDecoration(
                      labelText: "Transmission",
                    ),
                    items: ["Automatic", "Manual"].map((trans) {
                      return DropdownMenuItem<String>(
                        value: trans,
                        child: Text(trans),
                      );
                    }).toList(),
                    onChanged: (value) {
                      transmission.text = value ?? '';
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        flex: 2, // give more space to price input
                        child: TextFormField(
                          controller: price,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? "field required !"
                              : null,
                          decoration: const InputDecoration(
                            hintText: "Price in Local Currency",
                            border: UnderlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12), // spacing between fields
                      Expanded(
                        flex: 1, // less space for currency dropdown
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: "Currency",
                            border: UnderlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: "DZD", child: Text("DZD")),
                            DropdownMenuItem(value: "USD", child: Text("USD")),
                            DropdownMenuItem(value: "EUR", child: Text("EUR")),
                            DropdownMenuItem(value: "GBP", child: Text("GBP")),
                          ],
                          onChanged: (val) {
                            currancy.text = val ?? '';
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Select currency!"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (formstate.currentState!.validate()) {
                        if (_selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
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

                          String imgUrl = await FireStorage().uploadCarImage(
                            _selectedImage!,
                            carId,
                          );

                          // Save to user's subcollection
                          await FireCar.createCar(
                            carId,
                            vehiclefullname.text,
                            year.text,
                            transmission.text,
                            price.text,
                            imgUrl,
                            currancy.text,
                          );

                          // Save to global cars collection
                          await FireCar.firebaseFirestore
                              .collection('cars')
                              .doc(carId)
                              .set({
                                'id': carId,
                                'ownerId': user.uid,
                                'vehiclefullname': vehiclefullname.text,
                                'year': year.text,
                                'transmission': transmission.text,
                                'price': price.text,
                                'img': imgUrl,
                                'status': status.text.trim().isEmpty
                                    ? 'Available'
                                    : status.text.trim(),
                                'avaiableIn': 0, // ✅ initialize
                                'rentedAt': null, // ✅ keep consistent
                                'currancy': currancy.text,
                              });

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
                    child: const Text('ADD'),
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
