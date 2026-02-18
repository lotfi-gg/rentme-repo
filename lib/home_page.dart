import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rentme/create_page.dart';
import 'package:rentme/my_profile.dart';
import 'package:rentme/public_profile.dart';

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
              heroTag: "createBtn",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePage()),
                );
              },
              icon: Icon(Icons.car_rental_sharp),
              label: Text('CREATE'),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          SizedBox(
            width: 150,
            child: FloatingActionButton.extended(
              heroTag: "rentBtn",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Search By Location",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Country",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            items: ["Algeria", "Morocco", "Tunisia"].map((
                              country,
                            ) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                            onChanged: (value) {
                              print("Selected Country: $value");
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Province",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            items: ["Oran", "Algiers", "Constantine"].map((
                              province,
                            ) {
                              return DropdownMenuItem<String>(
                                value: province,
                                child: Text(province),
                              );
                            }).toList(),
                            onChanged: (value) {
                              print("Selected Province: $value");
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "Town Hall",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            items:
                                [
                                  "Algeria",
                                  "Morocco",
                                  "El Ançor",
                                  "Bousfer",
                                  "Hassi Ben Okba",
                                ].map((townhall) {
                                  return DropdownMenuItem<String>(
                                    value: townhall,
                                    child: Text(townhall),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              print("Selected Town Hall: $value");
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              null;
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(150, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text("FIND"),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.search),
              label: Text('RENT'),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        actions: [
          SizedBox(width: 12),
          IconButton(
            onPressed: () async {
              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.disconnect();
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('auth', (route) => false);
            },
            icon: Icon(Iconsax.logout),
            iconSize: 25,
          ),
          Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfile()),
              );
            },
            child: CircleAvatar(
              radius: 23,
              backgroundImage: AssetImage('images/user logo.png'),
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 130,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PublicProfile()),
                    );
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        child: Image.asset(
                          'images/user logo.png',
                          height: double.infinity,

                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Province / Town Hall'),
                            SizedBox(height: 8),
                            Text('Agency Name'),
                            SizedBox(height: 8),
                            Text('Avaiable Vehicles'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
