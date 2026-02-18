import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentme/firebase/fire_auth.dart';
import 'package:rentme/firebase/fire_storage.dart';
import 'package:rentme/models/user_model.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
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
          child: Column(
            children: [
              SizedBox(height: 40),
              TextFormField(
                controller: username,
                decoration: InputDecoration(
                  hintText: "Full Name",

                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: phonenumber,
                decoration: InputDecoration(
                  hintText: "Psone Number",
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: agencyname,
                decoration: InputDecoration(
                  hintText: "Agency Name",
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: country,
                decoration: InputDecoration(
                  hintText: "Country",
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: province,
                decoration: InputDecoration(
                  hintText: "Province",
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: townhall,
                decoration: InputDecoration(
                  hintText: "Town Hall",
                  border: UnderlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  if (username.text.isNotEmpty) {
                    await FirebaseAuth.instance.currentUser!
                        .updateDisplayName(username.text)
                        .then(
                          (value) => FireAuth.createUser(
                            int.parse(phonenumber.text),
                            agencyname.text,
                            country.text,
                            province.text,
                            townhall.text,
                          ),
                        );
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('myprofile', (route) => false);
                    print('user created -----------');
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: Size(250, 48)),
                child: Text('SAVE AND CONTINUE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
