import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart'; // for SystemNavigator.pop()

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "You must grant location permission to use this app.\n\n"
          "If you denied permanently, please enable it in Settings.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              LocationPermission permission =
                  await Geolocator.requestPermission();
              if (permission == LocationPermission.deniedForever) {
                await Geolocator.openAppSettings();
              } else if (permission == LocationPermission.denied) {
                _showPermissionDialog();
              }
            },
            child: const Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              SystemNavigator.pop(); // exit app
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  // ✅ Check both permission and GPS service
  Future<bool> _checkLocationPermissionAndService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("Location services must be enabled.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await _showPermissionDialog();
      return false;
    }

    return true;
  }

  Future signInWithGoogle() async {
    bool hasPermission = await _checkLocationPermissionAndService();
    if (!hasPermission) return;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': userCredential.user?.email,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('homepage', (route) => false);
      }
    } catch (e) {
      _showError("Error during Google sign-in: $e");
    }
  }

  Future<void> signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    bool hasPermission = await _checkLocationPermissionAndService();
    if (!hasPermission) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastLogin': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('homepage', (route) => false);
      }
    } catch (e) {
      _showError("Login failed: $e");
    }
  }

  Future<void> signUpWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    bool hasPermission = await _checkLocationPermissionAndService();
    if (!hasPermission) return;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': emailController.text.trim(),
            'latitude': position.latitude,
            'longitude': position.longitude,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('homepage', (route) => false);
      }
    } catch (e) {
      _showError("Signup failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/car.jpg', height: 200),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Email cannot be empty";
                      if (!RegExp(
                        r'^[^@]{5,}@[^@]{5,}\.[^@]+$',
                      ).hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Password cannot be empty";
                      if (value.length < 6)
                        return "Password must be at least 6 characters";
                      return null;
                    },
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signInWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('LOGIN'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signUpWithEmailPassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('SIGN UP'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('LOGIN WITH GOOGLE'),
                        const SizedBox(width: 8),
                        Image.asset(
                          'images/google logo.jpg',
                          width: 40,
                          fit: BoxFit.contain,
                        ),
                      ],
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
}
