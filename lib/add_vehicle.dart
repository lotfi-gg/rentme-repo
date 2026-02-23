import 'package:flutter/material.dart';
import 'package:rentme/firebase/fire_auth.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  TextEditingController vehiclefullname = TextEditingController();
  TextEditingController year = TextEditingController();
  TextEditingController transmission = TextEditingController();
  TextEditingController price = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: formstate,
              child: Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.red,
                      image: DecorationImage(
                        image: AssetImage("images/image1.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(onPressed: () {}, child: Text('ADD PHOTOS')),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: vehiclefullname,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Vehicle Full Name",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: year,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Year",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: "Transmission"),
                    items: ["Automatic", "Manual"].map((Transmission) {
                      return DropdownMenuItem<String>(
                        value: Transmission,
                        child: Text(Transmission),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        transmission.text = value ?? '';
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: price,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "field required !";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Price in Local Curancy",
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () async {
                      if (formstate.currentState!.validate()) {
                        try {
                          await FireCar.createCar(
                            vehiclefullname: vehiclefullname.text,
                            year:year.text,
                            transmission: transmission.text,
                            price: price.text,
                          );
                          Navigator.of(context).pushNamed('myprofile');
                          print('user created -----------');
                        } catch (e) {
                          print('error while creating page ======> $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(minimumSize: Size(250, 48)),
                    child: Text('ADD'),
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
