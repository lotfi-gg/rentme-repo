import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddCars extends StatefulWidget {
  const AddCars({super.key});

  @override
  State<AddCars> createState() => _AddCarsState();
}

class _AddCarsState extends State<AddCars> {
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
              icon: Icon(Icons.add),
              label: Text('ADD CAR'),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          SizedBox(
            width: 150,
            child: FloatingActionButton.extended(
              onPressed: () {},
              icon: Icon(Icons.check),
              label: Text('SAVE'),
            ),
          ),
        ],
      ),

      appBar: AppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('images/image1.jpg', height: 150),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: 150,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              child: Image.asset(
                                'images/image1.jpg',
                                height: double.infinity,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Title'),
                                  Text('Subtitle'),
                                  Row(
                                    children: [
                                      Text('Color'),
                                      Spacer(),
                                      Text('Rented'),
                                      SizedBox(width: 15),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Auto or Manual'),
                                      Spacer(),
                                      Text('Time'),
                                      SizedBox(width: 15),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
