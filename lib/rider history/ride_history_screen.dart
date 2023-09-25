import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:user_fyp/global/global.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<dynamic>(
          stream: FirebaseDatabase.instance
              .ref()
              .child("requestRides")
              .child(currentFirebaseUser!.uid)
              .onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(
                  child: Text('No Ride History available yet'));
            }

            Map data = snapshot.data!.snapshot.value;

            return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4, // Shadow elevation
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text("Driver name: ${data['driver_name']} "),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: ${data['status']}'),
                            Text('From: ${data['pickupLocation']}'),
                            Text('To: ${data['dropOffLocation']}'),
                            Text('Fare: ${data['total_price']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
