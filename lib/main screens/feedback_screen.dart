import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_fyp/global/global.dart';

import '../info handler/app_info.dart';
import '../info handler/directions.dart';
import 'main_screen.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({Key? key}) : super(key: key);

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  TextEditingController controller = TextEditingController();
  int indexList = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final userLocationInfo = Provider.of<AppInfo>(context);
    return SafeArea(
      child: Scaffold(
        body: Stack(children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Padding(
              padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Text(
                    'Rate your experience with the Rider',
                    style: TextStyle(
                        fontSize: size.height * 0.02, color: Colors.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text(
                      'Send Feedback:',
                      style: TextStyle(
                          fontSize: size.height * 0.017, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        'Share your feedback about the rider and the service',
                        style: TextStyle(
                            fontSize: size.height * 0.017, color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                          hintText: 'Enter feedback here'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Row(
                      children: [
                        const Text("Rate Rider"),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              indexList =
                                  1; // Assuming indexList is a single integer variable
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color: indexList >= 1 ? Colors.yellow : Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              indexList = 2;
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color: indexList >= 2 ? Colors.yellow : Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              indexList = 3;
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color: indexList >= 3 ? Colors.yellow : Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              indexList = 4;
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color: indexList >= 4 ? Colors.yellow : Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              indexList = 5;
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color: indexList == 5 ? Colors.yellow : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 50),
                    child: CupertinoButton(
                        color: Colors.blue,
                        child: const Text('Submit Feedback'),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
                        

                          FirebaseDatabase firebaseDatabase =
                              FirebaseDatabase.instance;

                          DatabaseReference userRef = firebaseDatabase
                              .ref()
                              .child('requestRides')
                              .child(currentFirebaseUser!.uid)
                              .child('driver_id');

                          userRef.once().then((snapshot) {
                            dynamic driverId = snapshot.snapshot.value;
                            firebaseDatabase
                                .ref()
                                .child('feedback')
                                .child(driverId)
                                .push()
                                .set({
                              'feedback': controller.text,
                              'rating': indexList.toString(),
                            }).then((value) {
                              userLocationInfo.resetValues();

                              FirebaseDatabase.instance
                                  .ref()
                                  .child(currentFirebaseUser!.uid)
                                  .remove();

                            });
                          }).catchError((error) {
                            print('Failed to retrieve user ID: $error');
                          });
                        }),
                  )
                ],
              ),
            ),
          ),

          // sab se top wala portion
          // Container(
          //       width: size.width,
          //       height: size.height * 0.08,
          //       decoration: BoxDecoration(
          //           boxShadow: const [
          //             BoxShadow(
          //               offset: Offset(3, 3),
          //               color: Colors.grey,
          //               blurRadius: 5,
          //             )
          //           ],
          //           color: Colo,
          //           borderRadius: const BorderRadius.only(
          //               bottomLeft: Radius.circular(50),
          //               bottomRight: Radius.circular(50))),
          //       child: Row(
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.only(left: 40),
          //             child: GestureDetector(
          //               onTap: () {

          //               },
          //               child: Icon(
          //                 icon,
          //                 color: Colors.white,
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: EdgeInsets.only(left: fromleft),
          //             child: Center(
          //               child: Text(
          //                 title,
          //                 style: TextStyle(
          //                     fontSize: size.height * 0.02,
          //                     fontWeight: FontWeight.bold,
          //                     color: Colors.white),
          //               ),
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          // CustomBlueHeader(
          //     fromleft: 100,
          //     size: size,
          //     callback: () {
          //       Navigator.pop(context);
          //     },
          //     icon: Icons.arrow_back,
          //     title: 'FeedBack')
        ]),
      ),
    );
  }
}
