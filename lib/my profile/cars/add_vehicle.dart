import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentme/firebase/fire_auth.dart';
import 'package:rentme/firebase/fire_storage.dart';
import 'package:rentme/my%20profile/cars/my_vehicles.dart';

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
  TextEditingController currancy = TextEditingController();

  File? _selectedImage;

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.deepOrangeAccent,
                ),
                title: const Text(
                  "Take Photo",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.blueAccent,
                ),
                title: const Text(
                  "Choose from Gallery",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepOrangeAccent),
        title: const Text(
          "Add Vehicle",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: formstate,
              child: Column(
                children: [
                  // ✅ Image container
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF1E1E1E),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage("images/car.png"),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'ADD PHOTO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  _buildTextField(vehiclefullname, "Vehicle Full Name"),
                  const SizedBox(height: 20),
                  _buildTextField(
                    year,
                    "Year",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    style: const TextStyle(
                      color: Colors.white, // ✅ selected value text
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: const Color(
                      0xFF1E1E1E,
                    ), // ✅ dark dropdown background
                    iconEnabledColor:
                        Colors.deepOrangeAccent, // ✅ accent color for arrow
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Field required!"
                        : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.deepOrangeAccent,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                    ),
                    hint: const Text(
                      "Transmission", // ✅ explicit hint
                      style: TextStyle(
                        color: Colors.white,
                      ), // ✅ force hint text to white
                    ),
                    items: ["Automatic", "Manual"].map((trans) {
                      return DropdownMenuItem<String>(
                        value: trans,
                        child: Text(
                          trans,
                          style: const TextStyle(
                            color: Colors.white, // ✅ option text color
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      transmission.text = value ?? '';
                    },
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          price,
                          "Price",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          style: const TextStyle(
                            color: Colors.white, // ✅ selected value text
                            fontWeight: FontWeight.w500,
                          ),
                          dropdownColor: const Color(
                            0xFF1E1E1E,
                          ), // ✅ dark dropdown background
                          iconEnabledColor: Colors
                              .deepOrangeAccent, // ✅ accent color for arrow
                          hint: const Text(
                            "Currency", // ✅ explicit hint
                            style: TextStyle(
                              color: Colors.white, // ✅ force hint text to white
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.deepOrangeAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "DZD",
                              child: Text(
                                "DZD",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: "USD",
                              child: Text(
                                "USD",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            DropdownMenuItem(
                              value: "EUR",
                              child: Text(
                                "EUR",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
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
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (formstate.currentState!.validate()) {
                        if (_selectedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF1E1E1E),
                              content: Text(
                                "Please add a photo before creating the car",
                                style: TextStyle(color: Colors.white),
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
                                'status': 'Available',
                                'rentedAt': null,
                                'endTime': null,
                                'currancy': currancy.text,
                              });

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyVehicles(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                "Error while creating car: $e",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'ADD VEHICLE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.trim().isEmpty ? "Field required!" : null,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: const Color(0xFF1E1E1E), // ✅ dark anthracite background
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.deepOrangeAccent, // ✅ premium accent color
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    );
  }
}
