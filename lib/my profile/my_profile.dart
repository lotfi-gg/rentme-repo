import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentme/firebase/fire_auth.dart';
import 'package:rentme/firebase/fire_storage.dart';
import 'package:rentme/home/home_page.dart';
import 'package:rentme/models/user_model.dart';
import 'package:rentme/my%20profile/cars/my_vehicles.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  Future<void> _reloadUser() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        me = ChatUser.fromJson(doc.data()!);
      });
    }
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  TextEditingController username = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController agencyname = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController province = TextEditingController();
  TextEditingController townhall = TextEditingController();
  String _img = '';
  ChatUser? me;
  bool readonly = true;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) {
          if (doc.exists) {
            setState(() {
              me = ChatUser.fromJson(doc.data()!);
              username.text = me!.username!;
              phonenumber.text = me!.phonenumber!;
              agencyname.text = me!.agencyname!;
              country.text = me!.country!;
              province.text = me!.province!;
              townhall.text = me!.townhall!;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  readonly = false;
                });
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'EDIT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // premium accent color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // smooth corners
                ),
                elevation: 4, // subtle shadow for depth
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (formstate.currentState!.validate()) {
                  setState(() {
                    readonly = true;
                  });
                  try {
                    await FirebaseAuth.instance.currentUser!
                        .updateDisplayName(username.text)
                        .then(
                          (value) => FireAuth.createUser(
                            phonenumber.text,
                            agencyname.text,
                            country.text,
                            province.text,
                            townhall.text,
                          ),
                        );

                    print('user updated -----------');
                  } catch (e) {
                    print('error while creating page ======> $e');
                  }
                } else {
                  setState(() {
                    readonly = false;
                  });
                }
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'SAVE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.greenAccent.shade700, // success accent color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () async {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepOrangeAccent, // premium accent
                  ),
                );
              },
            );

            // Optional: simulate a small delay or wait for async work
            await Future.delayed(const Duration(milliseconds: 200));

            // Navigate back to HomePage
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ).then((result) {
              if (result == true) {
                _reloadUser(); // refresh Firestore data
              }
            });

            // Close loading dialog after navigation
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            30,
            0,
            30,
            MediaQuery.of(context).size.height * 0.15,
          ),
          child: Form(
            key: formstate,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 70,
                      backgroundImage: _img.isNotEmpty
                          ? NetworkImage(_img) // ✅ always use URL
                          : (me?.img != null && me!.img!.isNotEmpty
                                ? NetworkImage(me!.img!)
                                : const AssetImage('images/user logo.png')),
                    ),


                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: IconButton.filled(
                        onPressed: () async {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) {
                              return SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Choose from Gallery'),
                                      onTap: () async {
                                        Navigator.pop(ctx);
                                        final image = await ImagePicker()
                                            .pickImage(
                                              source: ImageSource.gallery,
                                            );
                                        if (image != null) {
                                          final downloadUrl =
                                              await FireStorage()
                                                  .updateprofilepicture(
                                                    file: File(image.path),
                                                  );
                                          if (downloadUrl.isNotEmpty) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid,
                                                )
                                                .update({'img': downloadUrl});
                                            setState(() {
                                              _img =
                                                  downloadUrl; // ✅ use URL for CircleAvatar
                                            });
                                          }
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Take a Photo'),
                                      onTap: () async {
                                        Navigator.pop(ctx);
                                        final image = await ImagePicker()
                                            .pickImage(
                                              source: ImageSource.camera,
                                            );
                                        if (image != null) {
                                          final downloadUrl =
                                              await FireStorage()
                                                  .updateprofilepicture(
                                                    file: File(image.path),
                                                  );
                                          if (downloadUrl.isNotEmpty) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid,
                                                )
                                                .update({'img': downloadUrl});
                                            setState(() {
                                              _img = downloadUrl;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Iconsax.edit),
                      ),


                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyVehicles()),
                    );
                  },
                  icon: const Icon(
                    Iconsax.car,
                    color: Colors.white,
                  ), // modern car icon
                  label: const Text(
                    'MY VEHICLES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.deepPurpleAccent, // premium accent color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    minimumSize: const Size(
                      180,
                      50,
                    ), // slightly larger for importance
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Field required!";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Full Name', // 👈 inside the field
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Field required!";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: phonenumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Phone Number', // 👈 inside the field
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900, // subtle dark background
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Field required!";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: agencyname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Agency Name', // 👈 inside the field
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.business,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900, // subtle dark background
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Field required!";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: country,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Country', // 👈 inside the field
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.public,
                      color: Colors.blueAccent,
                    ), // globe icon
                    filled: true,
                    fillColor: Colors.grey.shade900, // subtle dark background
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Field required!";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: province,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Province', // 👈 inside the field
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_city,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900, // subtle dark background
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Field required!";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: townhall,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Town Hall', // 👈 inside the field
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.blueAccent,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade900, // subtle dark background
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
