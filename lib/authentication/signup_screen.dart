import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_fyp/authentication/login_screen.dart';
import 'package:user_fyp/global/global.dart';
import 'package:user_fyp/splashScreen/splash_screen.dart';



import '../main screens/main_screen.dart';
import '../widgets/progress_dialog.dart';


class SignupScreen extends StatefulWidget {
  final String? mobileNo;
  const SignupScreen({this.mobileNo});
  //const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context)
  {
    TextEditingController nameTextEditingController = TextEditingController();
    TextEditingController emailTextEditingController = TextEditingController();
    TextEditingController phoneTextEditingController = TextEditingController();
    TextEditingController passwordTextEditingController = TextEditingController();

    saveUserInfo() async
    {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext c)
          {
            return ProgressDialogue(message: "Processing, please Wait",);
          }
      );
      final User? firebaseUser = (
      await fAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ).catchError((msg){
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Error: " + msg.toString());
      })
      ).user;


      // for realtime database
      if(firebaseUser!= null)
      
        {
          String phoneNumber = "0" + widget.mobileNo!;
          Map usersMap =
              {
              
                "id": firebaseUser.uid,
                "name": nameTextEditingController.text.trim(),
                "email": emailTextEditingController.text.trim(),
                "phone": phoneNumber,
              };
          DatabaseReference reference = FirebaseDatabase.instance.ref().child("users");
          reference.child(firebaseUser.uid).set(usersMap);
          currentFirebaseUser = firebaseUser;
          Fluttertoast.showToast(msg: "Account has been created.");
          Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));
        }
      else
        {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Account has not been created");
        }
    }





    validationForm()
    {
      if(nameTextEditingController.text.length < 3)
        {
         Fluttertoast.showToast(msg: "name mustbe at least 3 characters. ");
        }
      //validation...check
      else if (!emailTextEditingController.text.contains("@"))
        {
          Fluttertoast.showToast(msg: "Email address is not valid. ");
        }
      // else if (phoneTextEditingController.text.isEmpty)
      // {
      //   Fluttertoast.showToast(msg: "Phone Number is Required ");
      // }
      else if (passwordTextEditingController.text.length <6)
      {
        Fluttertoast.showToast(msg: "Password must be atleast 6 characters ");
      }
      else
        {
          saveUserInfo();

        }
    }




    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo1.jpg"),
              ),
              const SizedBox(height: 10,),
              const Text(
                "Register as User",
                style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold
                ),
              ),


              TextField(
                controller: nameTextEditingController,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                labelText: "Name",
                hintText: "Name",
                enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                  ),
                hintStyle: TextStyle(
  color: Colors.black,
  fontSize: 15,
  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),

  ),


          ),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),

                ),


              ),
              TextField(
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                enabled: false,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: widget.mobileNo,
                  hintText: "Phone Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),

                ),


              ),
              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),

                ),


              ),

              const SizedBox(height: 20,),

              ElevatedButton(
                  onPressed: ()
                  {
                    validationForm();
                    // Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
                  },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                ),
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                      color: Colors.black,
                    fontSize: 18,


                  ),
                ),
              ),
              TextButton(
                child: Text(
                    "Already have an Account? Login Here"
                ),
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
