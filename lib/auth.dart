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
  bool isLoading = false;

  void _setLoading(bool value) {
    if (!mounted) return; // ✅ évite l’erreur si le widget est détruit
    setState(() {
      isLoading = value;
    });
  }

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

  // login with google
  Future signInWithGoogle() async {
    _setLoading(true); // ✅ activer le loader
    bool hasPermission = await _checkLocationPermissionAndService();
    if (!hasPermission) {
      _setLoading(false);
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }

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
    } finally {
      _setLoading(false); // ✅ désactiver le loader
    }
  }

  // sign in with email and password
  Future<void> signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);

    bool hasPermission = await _checkLocationPermissionAndService();
    if (!hasPermission) {
      _setLoading(false);
      return;
    }

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
    } finally {
      _setLoading(false); // ✅ désactiver le loader
    }
  }

  // sign up with email and password
  Future<void> signUpWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);

    bool hasPermission = await _checkLocationPermissionAndService();
    if (!hasPermission) {
      _setLoading(false);
      return;
    }

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
    } finally {
      _setLoading(false); // ✅ désactiver le loader
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/car.png',

                        width: 500, // tu peux aussi fixer la largeur
                        fit: BoxFit
                            .contain, // ajuste le contenu sans déformation
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email cannot be empty";
                          }
                          if (!RegExp(
                            r'^[^@]{5,}@[^@]{5,}\.[^@]+$',
                          ).hasMatch(value)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                        controller: emailController,
                        style: const TextStyle(
                          color: Colors.white, // ✅ texte blanc pour contraste
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            color: Colors
                                .blueAccent, // ✅ couleur premium pour le label
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.blueAccent, // ✅ icône élégante
                          ),
                          filled: true,
                          fillColor: Colors.black, // ✅ fond uniforme
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.blueAccent, // ✅ bord premium
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors
                                  .deepOrangeAccent, // ✅ couleur accent au focus
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors
                                  .redAccent, // ✅ couleur claire pour erreurs
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password cannot be empty";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        obscureText: true,
                        controller: passwordController,
                        style: const TextStyle(
                          color: Colors.white, // ✅ texte blanc pour contraste
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Colors
                                .blueAccent, // ✅ couleur premium pour le label
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock, // ✅ icône cadenas pour password
                            color: Colors.blueAccent,
                          ),
                          filled: true,
                          fillColor: Colors.black, // ✅ fond uniforme
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.blueAccent, // ✅ bord premium
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors
                                  .deepOrangeAccent, // ✅ couleur accent au focus
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors
                                  .redAccent, // ✅ couleur claire pour erreurs
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: signInWithEmailPassword,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            50,
                          ), // ✅ largeur max, hauteur confortable
                          backgroundColor:
                              Colors.blueAccent, // ✅ couleur premium cohérente
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // ✅ coins arrondis modernes
                          ),
                          elevation:
                              6, // ✅ ombre subtile pour donner de la profondeur
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 20, // ✅ taille de texte lisible
                            fontWeight: FontWeight
                                .bold, // ✅ texte fort et professionnel
                            color:
                                Colors.white, // ✅ contraste fort sur fond bleu
                            letterSpacing: 1.5, // ✅ espacement élégant
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: signUpWithEmailPassword,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            50,
                          ), // ✅ largeur max, hauteur confortable
                          backgroundColor: Colors
                              .deepOrangeAccent, // ✅ couleur premium différente pour le distinguer
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // ✅ coins arrondis modernes
                          ),
                          elevation:
                              6, // ✅ ombre subtile pour donner de la profondeur
                        ),
                        child: const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 20, // ✅ taille de texte lisible
                            fontWeight: FontWeight
                                .bold, // ✅ texte fort et professionnel
                            color: Colors
                                .white, // ✅ contraste fort sur fond orange
                            letterSpacing: 1.5, // ✅ espacement élégant
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            50,
                          ), // ✅ largeur max
                          backgroundColor: Colors
                              .white, // ✅ fond blanc pour respecter l’identité Google
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // ✅ coins arrondis modernes
                            side: const BorderSide(
                              color: Colors.blueAccent,
                              width: 1.5,
                            ), // ✅ bord premium
                          ),
                          elevation: 6, // ✅ ombre subtile
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/google logo.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'LOGIN WITH GOOGLE',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .black, // ✅ texte noir pour contraste sur fond blanc
                                letterSpacing: 1.2,
                              ),
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
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.6), // fond semi-transparent
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrangeAccent,
                  strokeWidth: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
