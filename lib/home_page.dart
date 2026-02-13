import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: FloatingActionButton.extended(
              onPressed: () {},
              icon: Icon(Icons.car_rental_sharp),
              label: Text('CREATE'),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          SizedBox(
            width: 150,
            child: FloatingActionButton.extended(
              onPressed: () {},
              icon: Icon(Icons.search),
              label: Text('RENT'),
            ),
          ),
        ],
      ),
      appBar: AppBar(),
      body: Text('welcome'),
    );
  }
}
