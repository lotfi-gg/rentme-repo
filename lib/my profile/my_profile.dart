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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: FloatingActionButton.extended(
              heroTag: "EDITBtn",
              onPressed: () {
                setState(() {
                  readonly = false;
                });
              },
              icon: Icon(Icons.edit),
              label: Text('EDIT'),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: FloatingActionButton.extended(
              heroTag: "SAVEBtn",
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
              icon: Icon(Icons.check),
              label: Text('SAVE'),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ).then((result) {
              if (result == true) {
                _reloadUser(); // refresh Firestore data
              }
            });
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
                      radius: 70,
                      backgroundImage: _img.isNotEmpty
                          ? FileImage(File(_img))
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
                                          setState(() {
                                            _img = image.path;
                                          });
                                          FireStorage().updateprofilepicture(
                                            file: File(image.path),
                                          );
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
                                          setState(() {
                                            _img = image.path;
                                          });
                                          FireStorage().updateprofilepicture(
                                            file: File(image.path),
                                          );
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "field required !";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: username,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "field required !";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: phonenumber,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "field required !";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: agencyname,
                  decoration: InputDecoration(
                    labelText: 'Agency Name',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "field required !";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: country,
                  decoration: InputDecoration(
                    labelText: 'Country',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "field required !";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: province,
                  decoration: InputDecoration(
                    labelText: 'Province',
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "field required !";
                    }
                    return null;
                  },
                  readOnly: readonly,
                  controller: townhall,
                  decoration: InputDecoration(
                    labelText: 'Town Hall',
                    border: UnderlineInputBorder(),
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
