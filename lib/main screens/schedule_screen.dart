import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_fyp/global/global.dart';
import 'package:user_fyp/main%20screens/route_screen.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  TextEditingController fromLocationController = TextEditingController();
  TextEditingController toLocationController = TextEditingController();
  TextEditingController faresController = TextEditingController();
  String isDaily = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carpool Schedules'),
        centerTitle: true,
      ),
      body: StreamBuilder<dynamic>(
          stream: FirebaseDatabase.instance.ref().child("schedule").onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data!.snapshot.value == null) {
              return const Center(
                  child: Text('No Schdule available right now'));
            }
            Map data = snapshot.data!.snapshot.value;

            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  var elementSelected = data.values.elementAt(index);
                  isDaily = data.values.elementAt(index)['isDaily'];
                  faresController.text =
                      data.values.elementAt(index)['fares'].toString();
                  return Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    height: 420,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Name: ${data.values.elementAt(index)['driver_name']}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Phone: ${data.values.elementAt(index)['driver_phone']}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Seats",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            Text(
                              data.values.elementAt(index)['seats'].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Available Seats",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            Text(
                              data.values
                                  .elementAt(index)['availableSeats']
                                  .toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: data.values
                                            .elementAt(index)['availableSeats']
                                            .toString() ==
                                        "0"
                                    ? Colors.red
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              "Total Stops",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            Text(
                              (data.values.elementAt(index)['route'].length-1).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 120,
                              height: 25,
                              decoration: BoxDecoration(
                                color: isDaily == "true"
                                    ? Colors.blue
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Daily",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDaily == "true"
                                          ? Colors.white
                                          : Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 120,
                              height: 25,
                              decoration: BoxDecoration(
                                color: isDaily == "false"
                                    ? Colors.blue
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "One Time",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDaily == "false"
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Text(
                              data.values.elementAt(index)['date'].toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            const Icon(Icons.calendar_today_outlined)
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              data.values.elementAt(index)['time'].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            const Icon(Icons.timer_outlined)
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Fare ammount",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            Text(
                              "RS "+data.values.elementAt(index)['fares'].toString() ,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "Vehicle Type",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            Text(
                              data.values.elementAt(index)['vehicleType'].toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                              width: 120,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ViewRouteScreen(scheduleID: data.values.elementAt(index)['scheduleID'])));                                  },
                                  child: const Text(
                                    "View Route",
                                    style: TextStyle(fontSize: 16),
                                  )),
                            ),
                            SizedBox(width: 10,),
                            FutureBuilder<bool>(
                              future: checkMyBooking(data.values.elementAt(index)['scheduleID']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // While the future is being processed, you can show a loading indicator.
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  // If there was an error, you can display an error message.
                                  return Text("Error: ${snapshot.error}");
                                } else {
                                  // If the future completed successfully, you can check the value and display the appropriate widget.
                                  bool isRideCompleted = snapshot.data ?? false; // Use false as the default value if snapshot.data is null.
                                  if (isRideCompleted) {
                                    return Text("");
                                  } else {
                                    return SizedBox(
                                      height: 40,
                                      width: 120,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                          ),
                                          onPressed: () {
                                            confirmSeats(elementSelected);
                                          },
                                          child: const Text(
                                            "Book Now",
                                            style: TextStyle(fontSize: 16),
                                          )),
                                    );
                                  }
                                }
                              },
                            ),

                          ],
                        )
                      ],

                    ),
                  );
                });
          }),
    );
  }

  Future<bool> checkMyBooking(scheduleID) async {
    DatabaseEvent event = await FirebaseDatabase.instance.ref()
        .child('booking')
        .orderByChild("passenger_id")
        .equalTo(currentFirebaseUser!.uid)
        .once();

    if (event.snapshot.value != null) {
      Map<Object?, Object?> bookings = event.snapshot.value as Map<Object?, Object?>;
      for (var value in bookings.values) {
        if (value != null) {
          Map<dynamic, dynamic> item = value as Map<dynamic, dynamic>;
          if  (item["scheduleID"] == scheduleID) {
            if (item["isDaily"] == "false" || item["isDaily"] == false) {
              return true;
            }
          }
          }
        }
      }
    return false;
    }


  void confirmSeats(element) {
    if (element['availableSeats'].toString() != "0") {
      String? selectedSeats = "1";
      String AvailableSeats = element['availableSeats'].toString();
      List<String> seats = List.generate(int.parse(AvailableSeats), (index) => (index + 1).toString());

      List<String> stopsList = [];
      String? selectedStop = "Origin";
      var  allRouteStops = element['route'];
      allRouteStops.forEach((route) {
        stopsList.add(route["title"]);
      });

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    content: Container(
                      height: 150, // Set the desired height here
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 25, child: Text("How many passengers?"),),
                          Container(
                            width: 220,
                            child: DropdownButton<String>(
                              value: selectedSeats,
                              hint: Text('Select number of seats'),
                              items: seats.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedSeats = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20, child: Text("Which stop will you join?"),),
                          Container(
                            width: 220,
                            child: DropdownButton<String>(
                              value: selectedStop,
                              hint: Text('Select the stop to join at'),
                              items: stopsList.map((String val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(
                                    val,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),

                              onChanged: (value) {
                                setState((){
                                  selectedStop = value;
                                });
                                setState(() {
                                  if (selectedStop == "Destination"){
                                    Fluttertoast.showToast(msg: "You cannot selected destination as pick up point");
                                    selectedStop= "Origin";
                                  }else{
                                    selectedStop = value;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        child: const Text('Submit'),
                        onPressed: () {BookRide(element, selectedSeats, selectedStop);},
                      ),
                    ],
                  );
                });
          });
    } else {
      Fluttertoast.showToast(
          msg: "No Seats Available",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
  void BookRide(element,selectedSeats, selectedStop){
    FirebaseDatabase.instance.ref().child("schedule").child(element["scheduleID"]).update({
      "availableSeats": (int.parse(element['availableSeats'].toString()) - int.parse(selectedSeats)).toString(),
    }).then((value) {
      DatabaseReference bookingRef = FirebaseDatabase.instance.ref().child('booking');
      DatabaseReference newBookingRef = bookingRef.push();
      String bookingID = newBookingRef.key!; // Get the generated key
      newBookingRef.set({
        "scheduleID" : element['scheduleID'].toString(),
        "status": "PENDING",
        "bookingID": bookingID,
        "seatsBooked": selectedSeats,
        "selectedStop": selectedStop,
        "isDaily": element['isDaily'],
        "dateBooked": element['date'],
        "timeBooked": DateFormat('h:mm a').format(DateTime.now()),
        "farePrice": element['fares'],
        "driver_id": element['driver_id'],
        "driver_name": element['driver_name'],
        "driver_phone": element['driver_phone'],
        "passenger_id": currentFirebaseUser!.uid,
        "passenger_name": userModelCurrentInfo!.name,
        "passenger_phone": userModelCurrentInfo!.phone,
        "passenger_status": "Waiting for approval",
      }).then((value) =>
          Navigator.pop(context));
    });
  }
}
