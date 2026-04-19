import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentme/firebase/fire_auth.dart';
import 'package:rentme/firebase/fire_storage.dart';
import 'package:rentme/models/car_model.dart';
import 'package:rentme/my%20profile/cars/my_vehicles.dart';

class EditVehicle extends StatefulWidget {
  final String carId;
  const EditVehicle({super.key, required this.carId});

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

class _EditVehicleState extends State<EditVehicle> {
  final String _img = '';
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  TextEditingController vehiclefullname = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController status = TextEditingController();
  TextEditingController transmission = TextEditingController();

  File? _selectedImage;

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
              vehiclefullname.text = myvehicle!.vehiclefullname ?? '';
              year.text = myvehicle!.year ?? '';
              price.text = myvehicle!.price ?? '';
              status.text = myvehicle!.status ?? '';
              transmission.text = myvehicle!.transmission ?? '';
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
                  // --- Image preview ---
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.noHeader,
                          animType: AnimType.scale,
                          body: SizedBox(
                            height: 300,
                            child:
                                (myvehicle?.images == null ||
                                    myvehicle!.images!.isEmpty)
                                // 👇 Show message if no images
                                ? Center(
                                    child: Text(
                                      'No images available.\nClick "Add Photos" to upload some.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                // 👇 Otherwise show the PageView with delete option
                                : StatefulBuilder(
                                    builder: (context, setStateDialog) {
                                      final PageController controller =
                                          PageController();
                                      return Stack(
                                        children: [
                                          PageView.builder(
                                            controller: controller,
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                myvehicle!.images!.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Image.network(
                                                  myvehicle!.images![index],
                                                  fit: BoxFit.contain,
                                                ),
                                              );
                                            },
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                int currentIndex =
                                                    controller.page?.round() ??
                                                    0;
                                                String imageUrl = myvehicle!
                                                    .images![currentIndex];

                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid,
                                                    )
                                                    .collection('cars')
                                                    .doc(widget.carId)
                                                    .update({
                                                      'images':
                                                          FieldValue.arrayRemove(
                                                            [imageUrl],
                                                          ),
                                                    });

                                                setStateDialog(() {
                                                  myvehicle!.images!.removeAt(
                                                    currentIndex,
                                                  );
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                          btnOkOnPress: () {}, // optional close button
                        ).show();
                      },
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey,
                          image: DecorationImage(
                            image: _img.isNotEmpty
                                ? FileImage(File(_img))
                                : (myvehicle?.img != null &&
                                          myvehicle!.img!.isNotEmpty
                                      ? NetworkImage(myvehicle!.img!)
                                      : const AssetImage('images/car.png')),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // 👇 Capture parent context before opening bottom sheet
                          final parentContext = context;

                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Wrap(
                                children: [
                                  // --- Gallery option ---
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Pick from Gallery'),
                                    onTap: () async {
                                      Navigator.pop(context); // close the sheet
                                      final ImagePicker imagePicker =
                                          ImagePicker();
                                      final List<XFile> images =
                                          await imagePicker.pickMultiImage();

                                      // 👇 If user cancels (no images picked)
                                      if (images.isEmpty) {
                                        if (!mounted) return;
                                        AwesomeDialog(
                                          context:
                                              parentContext, // 👈 use parent context
                                          dialogType: DialogType.info,
                                          animType: AnimType.scale,
                                          title: 'No Images Selected',
                                          desc: 'You did not pick any images.',
                                          btnOkOnPress: () {},
                                        ).show();
                                        return;
                                      }

                                      int existingCount =
                                          myvehicle?.images?.length ?? 0;
                                      int remainingSlots = 5 - existingCount;

                                      // 👇 If user picked more than allowed slots
                                      if (images.length > remainingSlots) {
                                        if (!mounted) return;
                                        AwesomeDialog(
                                          context:
                                              parentContext, // 👈 use parent context
                                          dialogType: DialogType.warning,
                                          animType: AnimType.scale,
                                          title: 'Too Many Images',
                                          desc:
                                              'You can only add $remainingSlots more photo(s). Please reduce your selection.',
                                          btnOkOnPress: () {},
                                        ).show();
                                        return;
                                      }

                                      // 👇 Upload selected images
                                      List<String> uploadedUrls = [];
                                      for (var img in images) {
                                        File file = File(img.path);
                                        String url = await FireStorage()
                                            .uploadCarImage(file, widget.carId);
                                        uploadedUrls.add(url);
                                      }

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          )
                                          .collection('cars')
                                          .doc(widget.carId)
                                          .update({
                                            'images': FieldValue.arrayUnion(
                                              uploadedUrls,
                                            ),
                                          });

                                      if (!mounted) return;
                                      setState(() {
                                        _selectedImage = File(
                                          images.first.path,
                                        );
                                      });
                                    },
                                  ),

                                  // --- Camera option ---
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Take Photo'),
                                    onTap: () async {
                                      Navigator.pop(context); // close the sheet
                                      final ImagePicker imagePicker =
                                          ImagePicker();
                                      final XFile? image = await imagePicker
                                          .pickImage(
                                            source: ImageSource.camera,
                                          );

                                      if (image == null) {
                                        if (!mounted) return;
                                        AwesomeDialog(
                                          context:
                                              parentContext, // 👈 use parent context
                                          dialogType: DialogType.info,
                                          animType: AnimType.scale,
                                          title: 'No Photo Taken',
                                          desc:
                                              'You did not capture any photo.',
                                          btnOkOnPress: () {},
                                        ).show();
                                        return;
                                      }

                                      int existingCount =
                                          myvehicle?.images?.length ?? 0;

                                      if (existingCount >= 5) {
                                        if (!mounted) return;
                                        AwesomeDialog(
                                          context:
                                              parentContext, // 👈 use parent context
                                          dialogType: DialogType.warning,
                                          animType: AnimType.scale,
                                          title: 'Limit Reached',
                                          desc:
                                              'You can only upload 5 photos maximum.',
                                          btnOkOnPress: () {},
                                        ).show();
                                        return;
                                      }

                                      File file = File(image.path);
                                      String url = await FireStorage()
                                          .uploadCarImage(file, widget.carId);

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          )
                                          .collection('cars')
                                          .doc(widget.carId)
                                          .update({
                                            'images': FieldValue.arrayUnion([
                                              url,
                                            ]),
                                          });

                                      if (!mounted) return;
                                      setState(() {
                                        _selectedImage = File(image.path);
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('edit Photo'),
                      ),

                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final List<XFile> images = await picker
                              .pickMultiImage();

                          // 👇 If user cancels (no images picked)
                          if (images.isEmpty) {
                            if (!mounted) return;
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.info,
                              animType: AnimType.scale,
                              title: 'No Images Selected',
                              desc: 'You did not pick any images.',
                              btnOkOnPress: () {},
                            ).show();
                            return;
                          }

                          // 👇 Check how many images already exist
                          int existingCount = myvehicle?.images?.length ?? 0;
                          int remainingSlots = 5 - existingCount;

                          // 👇 If no slots left
                          if (remainingSlots <= 0) {
                            if (!mounted) return;
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.scale,
                              title: 'Limit Reached',
                              desc: 'You already have 5 photos uploaded.',
                              btnOkOnPress: () {},
                            ).show();
                            return;
                          }

                          // 👇 If user picked more than allowed slots
                          if (images.length > remainingSlots) {
                            if (!mounted) return;
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.scale,
                              title: 'Too Many Images',
                              desc:
                                  'You can only add $remainingSlots more photo(s). Please reduce your selection.',
                              btnOkOnPress: () {},
                            ).show();
                            return;
                          }

                          // 👇 Upload selected images
                          List<String> uploadedUrls = [];
                          for (var img in images) {
                            File file = File(img.path);
                            String url = await FireStorage().uploadCarImage(
                              file,
                              widget.carId,
                            );
                            uploadedUrls.add(url);
                          }

                          // 👇 Overwrite Firestore with exactly the combined list (max 5)
                          List<String> currentImages = myvehicle?.images ?? [];
                          List<String> finalImages = [
                            ...currentImages,
                            ...uploadedUrls,
                          ].take(5).toList();

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('cars')
                              .doc(widget.carId)
                              .update({'images': finalImages});

                          if (!mounted) return;
                          setState(() {
                            _selectedImage = File(images.first.path);
                            myvehicle?.images =
                                finalImages; // update local state
                          });
                        },
                        child: const Text('Add Photos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    readOnly: readonly,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "field required !"
                        : null,
                    controller: vehiclefullname,
                    decoration: const InputDecoration(
                      hintText: "Vehicle Full Name",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    readOnly: readonly,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "field required !"
                        : null,
                    controller: year,
                    decoration: const InputDecoration(
                      hintText: "Year",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Transmission dropdown ---
                  DropdownButtonFormField<String>(
                    initialValue:
                        [
                          "Automatic",
                          "Manual",
                        ].contains(myvehicle?.transmission)
                        ? myvehicle?.transmission
                        : null,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "field required !"
                        : null,
                    decoration: const InputDecoration(
                      labelText: "Transmission",
                    ),
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
                          },
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    readOnly: readonly,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "field required !"
                        : null,
                    controller: price,
                    decoration: const InputDecoration(
                      hintText: "Price",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

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
                          maximumSize: const Size(100, 48),
                        ),
                        child: const Text('EDIT'),
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
                              final carId = widget.carId;

                              String imgUrl = myvehicle?.img ?? '';
                              if (_selectedImage != null) {
                                imgUrl = await FireStorage().uploadCarImage(
                                  _selectedImage!,
                                  carId,
                                );
                              }

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
                                    'img': imgUrl,
                                  });

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyVehicles(),
                                ),
                              );
                            } catch (e) {
                              print('Error while updating car ======> $e');
                            }
                          }
                        },
                        child: const Text('SAVE'),
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
