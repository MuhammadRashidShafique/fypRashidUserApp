// import 'dart:ffi';

// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';

// class Test extends StatefulWidget {
//   const Test({super.key});

//   @override
//   State<Test> createState() => _TestState();
// }

// class _TestState extends State<Test> {
//   @override
  // final ref = FirebaseDatabase.instance.ref('drivers');
  // Futurefunc() async {
  //   final databaseReference = FirebaseDatabase.instance.ref('');
    

  //   DatabaseReference dataRef = databaseReference.child("drivers/name");
  //   AsyncSnapshot<DatabaseEvent> dataSnapshot = dataRef.once().
  //   dynamic name = dataSnapshot.;
  //   print("chl bosdike");
  //   print(name);

  //   // double longitude =  dataSnapshot.snapshot.
  // }

//   Widget build(BuildContext context) {
//     print("hello guyz chai peelo");
//     print(Futurefunc());
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: ref.onValue,
//               builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//                 if (!snapshot.hasData) {
//                   return CircularProgressIndicator();
//                 } else {
//                   Map<dynamic, dynamic> map =
//                       snapshot.data!.snapshot.value as dynamic;
//                   List<dynamic> list = [];
//                   list.clear();

//                   list = map.values.toList();

//                   print("list");
//                   // print(list);

//                   return ListView.builder(
//                       itemCount: snapshot.data!.snapshot.children.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           title: Text(list[index]['longitude']),
//                           subtitle: Text(list[index]['latitude']),
//                         );
//                       });
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
