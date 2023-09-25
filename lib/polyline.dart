// import 'dart:async';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:user_fyp/global/map_key.dart';
//
//
//
// class PolylineScreen extends StatefulWidget {
//   const PolylineScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PolylineScreen> createState() => _PolylineScreenState();
// }
//
// class _PolylineScreenState extends State<PolylineScreen> {
//   static const CameraPosition initialPosition = CameraPosition(target: LatLng(24.8617, 67.0736), zoom: 13);
//   List<Marker> _marker =[];
//   final List<Marker> _list = const[
//   Marker(markerId: MarkerId('1'),
//     position: LatLng(24.7934, 67.1341),
//     infoWindow: InfoWindow(
//         title: 'KIET MAIN CAMPUS'
//     ),
//   ),
//       Marker(markerId: MarkerId('2'),
//   position: LatLng(24.8617,67.0736),
//   infoWindow: InfoWindow(
//   title: 'KIET CITY CAMPUS'
//   ),
//   ),
//   Marker(markerId: MarkerId('2'),
//   position: LatLng(24.9274,67.0476),
//   infoWindow: InfoWindow(
//   title: 'KIET NORTH CAMPUS'
//
//   ),
//   ),
// ];
//
//   final Completer<GoogleMapController> _controller = Completer();
//
//   String totalDistance = "";
//   String totalTime = "";
//
//   String apiKey = "$mapKey";
//   Position? userCurrentPosition;
//   LatLng origin = const LatLng(24.8617, 67.0736);
//
//   LatLng destination = const LatLng(24.7934, 67.1341);
//
//   PolylineResponse polylineResponse = PolylineResponse();
//
//   Set<Polyline> polylinePoints = {};
//   @override
//   void initState()
//   {
//     super.initState();
//
//     _marker.addAll(_list);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Polyline"),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             polylines: polylinePoints,
//             zoomControlsEnabled: false,
//             initialCameraPosition: initialPosition,
//             markers: Set<Marker>.of(_marker),
//             mapType: MapType.normal,
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//             },
//           ),
//           Container(
//             margin: const EdgeInsets.all(20),
//             padding: const EdgeInsets.all(20),
//             color: Colors.white,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text("Total Distance: " + totalDistance),
//                 Text("Total Time: " + totalTime),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           drawPolyline();
//         },
//         child: const Icon(Icons.directions),
//       ),
//     );
//   }
//
//   void drawPolyline() async {
//     var response = await http.post(Uri.parse("https://maps.googleapis.com/maps/api/directions/json?key=" +
//         apiKey +
//         "&units=metric&origin=" +
//         origin.latitude.toString() +
//         "," +
//         origin.longitude.toString() +
//         "&destination=" +
//         destination.latitude.toString() +
//         "," +
//         destination.longitude.toString() +
//         "&mode=driving"));
//
//     print(response.body);
//
//     polylineResponse = PolylineResponse.fromJson(jsonDecode(response.body));
//
//     totalDistance = polylineResponse.routes![0].legs![0].distance!.text!;
//     totalTime = polylineResponse.routes![0].legs![0].duration!.text!;
//
//     for (int i = 0; i < polylineResponse.routes![0].legs![0].steps!.length; i++) {
//       polylinePoints.add(Polyline(polylineId: PolylineId(polylineResponse.routes![0].legs![0].steps![i].polyline!.points!), points: [
//         LatLng(
//             polylineResponse.routes![0].legs![0].steps![i].startLocation!.lat!, polylineResponse.routes![0].legs![0].steps![i].startLocation!.lng!),
//         LatLng(polylineResponse.routes![0].legs![0].steps![i].endLocation!.lat!, polylineResponse.routes![0].legs![0].steps![i].endLocation!.lng!),
//       ],width: 3,color: Colors.red));
//     }
//
//     setState(() {});
//   }
// }
