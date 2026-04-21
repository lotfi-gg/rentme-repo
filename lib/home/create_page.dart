import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rentme/firebase/fire_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController phonenumber = TextEditingController();
  final TextEditingController agencyname = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController province = TextEditingController();
  final TextEditingController townhall = TextEditingController();

  bool _isLoading = false;

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.deepOrangeAccent),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.deepOrangeAccent,
        ), // orange back arrow
        title: const Text(
          "Create Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: formstate,
              child: Column(
                children: [
                  TextFormField(
                    controller: username,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Field required!"
                        : null,
                    decoration: _inputDecoration("Full Name", Icons.person),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: phonenumber,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Field required!"
                        : null,
                    decoration: _inputDecoration("Phone Number", Icons.phone),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: agencyname,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Field required!"
                        : null,
                    decoration: _inputDecoration("Agency Name", Icons.business),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: country,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Field required!"
                        : null,
                    decoration: _inputDecoration("Country", Icons.flag),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: province,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Field required!"
                        : null,
                    decoration: _inputDecoration(
                      "Province",
                      Icons.location_city,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: townhall,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Field required!"
                        : null,
                    decoration: _inputDecoration("Town Hall", Icons.home_work),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () async {
                      if (formstate.currentState!.validate()) {
                        setState(() => _isLoading = true); // show loader
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

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .set({
                                'hasCreated': true,
                              }, SetOptions(merge: true));

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isFirstTime', false);

                          setState(() => _isLoading = false); // hide loader

                          // ✅ Show success dialog
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E1E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Row(
                                children: const [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 36,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Agency Created",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              content: const Text(
                                "Your agency profile has been created successfully.\n\n"
                                "You can check your profile by clicking on the top‑left icon on the homepage.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx); // close dialog
                                    Navigator.pop(
                                      context,
                                      true,
                                    ); // return success
                                  },
                                  child: const Text(
                                    "OK",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          setState(() => _isLoading = false); // hide loader
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'SAVE AND CONTINUE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrangeAccent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
