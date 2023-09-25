import 'package:flutter/material.dart';
import 'package:user_fyp/global/global.dart';
import 'package:user_fyp/main%20screens/booking.dart';
import 'package:user_fyp/rider%20history/ride_history_screen.dart';
import 'package:user_fyp/splashScreen/splash_screen.dart';
import '../main screens/schedule_screen.dart';
import '../profile_Screen/profile_screen.dart';

class MyDrawer extends StatefulWidget {
  String? name;
  String? email;
  MyDrawer({this.name, this.email});
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //drawer header
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.black),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          //data print ho rha
                          widget.name.toString(),

                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.email.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                )),
          ),
          const SizedBox(
            height: 12.0,
          ),
          //drawer body
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RideHistoryScreen()));
            },
            child: const ListTile(
                leading: Icon(Icons.history, color: Colors.white),
                title: Text(
                  "History",
                  style: TextStyle(color: Colors.white54),
                )),
          ),
          const SizedBox(
            height: 12.0,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ScheduleScreen()));
            },
            child: const ListTile(
                leading: Icon(Icons.history, color: Colors.white),
                title: Text(
                  "view available carpol",
                  style: TextStyle(color: Colors.white54),
                )),
          ),
           const SizedBox(
            height: 12.0,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BookingScreen()));
            },
            child: const ListTile(
                leading: Icon(Icons.history, color: Colors.white),
                title: Text(
                  "Booked Rides",
                  style: TextStyle(color: Colors.white54),
                )),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()));
            },
            child: const ListTile(
                leading: Icon(Icons.person, color: Colors.white),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(color: Colors.white54),
                )),
          ),
          GestureDetector(
            onTap: () {},
            child: const ListTile(
                leading: Icon(Icons.info, color: Colors.white),
                title: Text(
                  "About",
                  style: TextStyle(color: Colors.white54),
                )),
          ),
          GestureDetector(
            onTap: () {
              fAuth.signOut();
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => const MySplashScreen()));
            },
            child: const ListTile(
                leading: Icon(Icons.logout, color: Colors.white),
                title: Text(
                  "Signout",
                  style: TextStyle(color: Colors.white54),
                )),
          ),
        ],
      ),
    );
  }
}
