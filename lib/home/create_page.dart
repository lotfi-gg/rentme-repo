import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/firebase/fire_auth.dart';
import 'package:rentme/my%20profile/my_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController agencyname = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController province = TextEditingController();
  TextEditingController townhall = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: formstate,
            child: Column(
              children: [
                SizedBox(height: 40),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "field required !";
                    }
                    return null;
                  },
                  controller: username,
                  decoration: InputDecoration(
                    hintText: "Full Name",

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
                  controller: phonenumber,
                  decoration: InputDecoration(
                    hintText: "Phone Number",
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
                  controller: agencyname,
                  decoration: InputDecoration(
                    hintText: "Agency Name",
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
                  controller: country,
                  decoration: InputDecoration(
                    hintText: "Country",
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
                  controller: province,
                  decoration: InputDecoration(
                    hintText: "Province",
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
                  controller: townhall,
                  decoration: InputDecoration(
                    hintText: "Town Hall",
                    border: UnderlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () async {
                    if (formstate.currentState!.validate()) {
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

                        // ✅ Mark hasCreated in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({'hasCreated': true});

                        // ✅ SharedPreferences if you still want local flag
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isFirstTime', false);

                        // ✅ Navigate back to HomePage and trigger refresh
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MyProfile()),
                        );

                        print('user created -----------');
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        print('error while creating page ======> $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 48),
                  ),
                  child: const Text('SAVE AND CONTINUE'),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
