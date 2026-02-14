import 'package:flutter/material.dart';
import 'package:rentme/auth.dart';
import 'package:rentme/home_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/image1.jpg', height: 240),
            SizedBox(height: 30),
            Text(
              'welcome to the renting app, the easiest to use',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 100),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Auth()),
                );
              },
              child: Text('continue', style: TextStyle(fontSize: 30)),
            ),
          ],
        ),
      ),
    );
  }
}
