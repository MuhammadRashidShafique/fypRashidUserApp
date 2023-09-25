import 'dart:async';

import 'package:flutter/material.dart';
import 'package:user_fyp/assistants/assistant_methods.dart';
import 'package:user_fyp/authentication/login_screen.dart';
import 'package:user_fyp/global/global.dart';
import 'package:user_fyp/main%20screens/main_screen.dart';



class MySplashScreen extends StatefulWidget
{
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  startTimer()
  {
    fAuth.currentUser!= null ?  AssistantMethods.readCurrentOnlineUserInfo() : null;

    Timer(const Duration(seconds: 5), () async {
      if (await fAuth.currentUser != null)
      {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
      }
      else
      {
        //send user to login screen
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }

    });
  }


  //jb bhi user page change kryga to y execute hoga
  @override
  void initState() {
    super.initState();
    startTimer();
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Image.asset("assets/images/logo1.jpg"),

                const SizedBox(height: 10,),



                const Text(
                  "    by Muhammad Rashid & Shaloom",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}
