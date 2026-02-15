import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rentme/auth.dart';
import 'package:rentme/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RentMe());
}

class RentMe extends StatefulWidget {
  const RentMe({super.key});

  @override
  State<RentMe> createState() => _RentMeState();
}

class _RentMeState extends State<RentMe> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } return Auth();
        },
      ),
      routes: {"homepage": (context) => HomePage(),
        "auth": (context) => Auth(),
      },
    );
  }
}
