import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentme/firebase/fire_auth.dart';
import 'package:rentme/firebase/fire_storage.dart';
import 'package:rentme/models/car_model.dart';
import 'package:rentme/my_vehicles.dart';

class EditVehicle extends StatefulWidget {
  final String carId; // <-- add this
  const EditVehicle({super.key, required this.carId});

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

class _EditVehicleState extends State<EditVehicle> {
  String _img = '';
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  TextEditingController vehiclefullname = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController status = TextEditingController();
  TextEditingController transmission = TextEditingController();

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

  CarInfo? myvehicle;
  bool readonly = true;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cars')
        .doc(widget.carId)
        .get()
        .then((doc) {
          if (doc.exists) {
            setState(() {
              myvehicle = CarInfo.fromJson(doc.data()!);
              vehiclefullname.text = myvehicle!.vehiclefullname!;
              year.text = myvehicle!.year!;
              price.text = myvehicle!.price!;
              status.text = myvehicle!.status!;
            });
          }
        });
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
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red,
                            image: DecorationImage(
                              image: _img.isNotEmpty
                                  ? FileImage(File(_img))
                                  : (myvehicle?.img != null &&
                                            myvehicle!.img!.isNotEmpty
                                        ? NetworkImage(myvehicle!.img!)
                                        : const AssetImage('images/car.jpg')),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          right: 50,
                          child: IconButton.filled(
                            onPressed: () async {
                              ImagePicker imagePicker = ImagePicker();
                              XFile? image = await imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                setState(() {
                                  _img = image.path;
                                });
                                FireStorage().uploadCarImage(
                                  File(image.path),
                                  widget.carId,
                                );
                              }
                            },
                            icon: Icon(Iconsax.edit),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: 230,
                          child: IconButton.filled(
                            onPressed: () async {},
                            icon: Icon(Iconsax.add),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                  TextFormField(
                    readOnly: readonly,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    controller: vehiclefullname,
                    decoration: InputDecoration(
                      hintText: "Vehicle Full Name",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    readOnly: readonly,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    controller: year,
                    decoration: InputDecoration(
                      hintText: "Year",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    initialValue: myvehicle?.transmission,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: "Transmission"),
                    items: ["Automatic", "Manual"].map((transmission) {
                      return DropdownMenuItem<String>(
                        value: transmission,
                        child: Text(transmission),
                      );
                    }).toList(),
                    onChanged: readonly
                        ? null
                        : (value) {
                            setState(() {
                              transmission.text = value ?? '';
                            });
                            print('-----Transmission-----> $value');
                          },
                  ),
                  SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    initialValue: myvehicle?.status,
                    validator: (value) {
                      setState(() {
                        readonly = true;
                      });
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: "Status"),
                    items: ["Avaiable", "Rented"].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: readonly
                        ? null
                        : (value) {
                            print('-----Status-----> $value');
                          },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    readOnly: readonly,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    controller: price,
                    decoration: InputDecoration(
                      hintText: "Price",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            readonly = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          maximumSize: Size(100, 48),
                        ),
                        child: Text('EDIT'),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.2),

                      ElevatedButton(
                        onPressed: () async {
                          if (formstate.currentState!.validate()) {
                            setState(() {
                              readonly = true;
                            });
                            try {
                              final user = FireCar.auth.currentUser!;
                              final carId = widget.carId; // ✅ use existing ID

                              String imgUrl =
                                  myvehicle?.img ?? ''; // fallback to old image
                              if (_selectedImage != null) {
                                // upload new image and get URL
                                imgUrl = await FireStorage().uploadCarImage(
                                  _selectedImage!,
                                  carId,
                                );
                              }

                              // update existing car
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('cars')
                                  .doc(carId)
                                  .update({
                                    'vehiclefullname':
                                        vehiclefullname.text.isNotEmpty
                                        ? vehiclefullname.text
                                        : myvehicle?.vehiclefullname,
                                    'year': year.text.isNotEmpty
                                        ? year.text
                                        : myvehicle?.year,
                                    'transmission': transmission.text.isNotEmpty
                                        ? transmission.text
                                        : myvehicle?.transmission,
                                    'price': price.text.isNotEmpty
                                        ? price.text
                                        : myvehicle?.price,
                                    'status': status.text.isNotEmpty
                                        ? status.text
                                        : myvehicle?.status,
                                    'img': _selectedImage != null
                                        ? await FireStorage().uploadCarImage(
                                            _selectedImage!,
                                            carId,
                                          )
                                        : myvehicle?.img,
                                  });

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyVehicles(),
                                ),
                              );

                              print('Car updated successfully -----------');
                            } catch (e) {
                              print('Error while updating car ======> $e');
                            }
                          }
                          setState(() {
                            readonly = false;
                          });
                        },
                        child: Text('SAVE'),
                      ),
                    ],
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
