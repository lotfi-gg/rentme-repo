import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rentme/auth.dart';
import 'package:rentme/home/home_page.dart';
import 'package:rentme/my%20profile/my_profile.dart';
import 'package:rentme/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;
  runApp(RentMe(isFirstTime: isFirstTime));
}

class RentMe extends StatefulWidget {
  final bool isFirstTime;
  const RentMe({super.key, required this.isFirstTime});

  @override
  State<RentMe> createState() => _RentMeState();
}

class _RentMeState extends State<RentMe> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: widget.isFirstTime
          ? WelcomePage()
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return HomePage();
                }
                return Auth(); // login/signup page
              },
            ),
      routes: {
        "homepage": (context) => HomePage(),
        "auth": (context) => Auth(),
        "myprofile": (context) => MyProfile(),
      },
    );
  }
}
