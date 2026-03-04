import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentme/models/car_model.dart';
import 'package:rentme/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicProfile extends StatefulWidget {
  final ChatUser user;
  const PublicProfile({super.key, required this.user});

  @override
  State<PublicProfile> createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  TextEditingController comment = TextEditingController();
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late String myRatings = '';
  void _showRatingDialog(BuildContext context) {
    int selectedStars = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Rate this service"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedStars = index + 1;
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser!;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.id)
                    .collection('ratings')
                    .doc(currentUser.uid) // ✅ ensures one rating per user
                    .set({
                      'stars': selectedStars,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.5),
              SizedBox(width: MediaQuery.of(context).size.width * 0.2),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                child: FloatingActionButton(
                  heroTag: "locationBtn",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(30),
                  ),
                  mini: true,
                  onPressed: () async {
                    final lat = widget.user.latitude;
                    final lng = widget.user.longitude;
                    if (lat != null && lng != null) {
                      final Uri mapsUri = Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
                      );

                      try {
                        await launchUrl(
                          mapsUri,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Could not open location"),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No location available")),
                      );
                    }
                  },
                  child: const Icon(Icons.location_on, color: Colors.red),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: FloatingActionButton.extended(
                  heroTag: "callBtn",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(30),
                  ),

                  onPressed: () async {
                    // Get the phone number from Firestore
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.user.id)
                        .get();

                    final phoneNumber = userDoc.data()?['phonenumber'];

                    if (phoneNumber != null && phoneNumber.isNotEmpty) {
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: phoneNumber,
                      );
                      await launchUrl(launchUri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("No phone number available")),
                      );
                    }
                  },
                  icon: Icon(Icons.phone),
                  label: Text('CALL'),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.2),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,

                child: FloatingActionButton.extended(
                  heroTag: "commentBtn",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(30),
                  ),
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
                        return SafeArea(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Comments",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.user.id) // profile owner
                                          .collection('comments')
                                          .orderBy(
                                            'createdAt',
                                            descending: true,
                                          )
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.data!.docs.isEmpty) {
                                          return Center(
                                            child: Text("No comments yet"),
                                          );
                                        }

                                        final comments = snapshot.data!.docs;

                                        return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: comments.length,
                                          itemBuilder: (context, index) {
                                            final data =
                                                comments[index].data()
                                                    as Map<String, dynamic>;
                                            final Timestamp? ts =
                                                data['createdAt'];
                                            String formattedDate = '';
                                            if (ts != null) {
                                              DateTime dt = ts.toDate();
                                              formattedDate = DateFormat(
                                                'dd/MM/yyyy HH:mm',
                                              ).format(dt);
                                            }
                                            return Column(
                                              children: [
                                                ListTile(
                                                  leading:
                                                      (data['img'] != null &&
                                                          data['img']
                                                              .isNotEmpty)
                                                      ? CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                data['img'],
                                                              ),
                                                        )
                                                      : CircleAvatar(
                                                          child: Icon(
                                                            Icons.person,
                                                          ),
                                                        ),
                                                  title: Row(
                                                    children: [
                                                      Text(
                                                        data['commenterName'],
                                                      ),
                                                      Spacer(),
                                                      Text(
                                                        formattedDate,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  subtitle: Text(
                                                    data['text'] ?? '',
                                                  ),
                                                ),
                                                Divider(thickness: 1),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Form(
                                          key: formstate,
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return null;
                                              }
                                              return null;
                                            },
                                            controller: comment,
                                            decoration: InputDecoration(
                                              hintText: "Add a comment...",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (formstate.currentState!
                                              .validate()) {
                                            final userId = widget
                                                .user
                                                .id; // the profile owner
                                            final currentUser = FirebaseAuth
                                                .instance
                                                .currentUser!; // commenter
                                            final userDoc =
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(currentUser.uid)
                                                    .get();
                                            final userImg =
                                                userDoc.data()?['img'] ?? '';
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userId)
                                                .collection(
                                                  'comments',
                                                ) // ✅ new subcollection
                                                .add({
                                                  'text': comment.text.trim(),
                                                  'commenterId':
                                                      currentUser.uid,
                                                  'commenterName':
                                                      currentUser.email
                                                          ?.split('@')
                                                          .first ??
                                                      'Anonymous',
                                                  'createdAt':
                                                      FieldValue.serverTimestamp(),
                                                  'img': userImg,
                                                });

                                            comment.clear(); // reset text field

                                            print("Comment submitted");
                                          } else {
                                            print(
                                              "you didnt submit any comment",
                                            );
                                          }
                                        },
                                        child: Icon(Icons.send),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.messenger_outline),
                  label: Text('COMMENTS'),
                ),
              ),
            ],
          ),
        ],
      ),
      appBar: AppBar(title: Text(widget.user.agencyname!)),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            CircleAvatar(
              radius: 50,
              child: Image.asset('images/user logo.png', height: 150),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.user.id)
                  .collection('ratings')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return InkWell(
                    onTap: () {
                      _showRatingDialog(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        );
                      }),
                    ),
                  );
                }

                final ratings = snapshot.data!.docs
                    .map(
                      (doc) =>
                          (doc.data() as Map<String, dynamic>)['stars'] as int,
                    )
                    .toList();

                final avgRating =
                    ratings.reduce((a, b) => a + b) / ratings.length;
                myRatings = ratings.length.toString();

                return InkWell(
                  onTap: () {
                    _showRatingDialog(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < avgRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      );
                    }),
                  ),
                );
              },
            ),

            SizedBox(height: 10),
            Text('Ratings: $myRatings'),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.id) // ChatUser id
                    .collection('cars')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No cars found"));
                  }

                  final cars = snapshot.data!.docs.map((doc) {
                    return CarInfo.fromJson(
                      doc.data()! as Map<String, dynamic>,
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 150,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 15,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(25),
                                      ),
                                      child:
                                          (car.img != null &&
                                              car.img!.isNotEmpty)
                                          ? Image.network(
                                              car.img!,
                                              height: double.infinity,
                                              width: 200,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'images/car.jpg',
                                              height: double.infinity,
                                              width: 200,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(car.vehiclefullname ?? ''),
                                          SizedBox(height: 5),
                                          Text(car.year ?? ''),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(car.transmission ?? ''),
                                              Spacer(),
                                              Text(car.status ?? ''),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text("Price: ${car.price}"),
                                              Spacer(),
                                              Text('Time left'),
                                            ],
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
                    },
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
