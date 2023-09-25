import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'assistants/assistant_methods.dart';

class PolylineScreen1 extends StatefulWidget {
const PolylineScreen1({Key? key}) : super(key: key);

@override
_PolylineScreen1State createState() => _PolylineScreen1State();
}

class _PolylineScreen1State extends State<PolylineScreen1> {

late GoogleMapController mapController;

// double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
// double _destLatitude = 6.849660, _destLongitude = 3.648190;
  Position? userCurrentPosition;
  GoogleMapController? newGoogleMapController;
  locateUserPosition() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);
  }

  double _originLatitude = 24.91592216115243,

_originLongitude = 67.08821259817404;
double _destLatitude = 24.912419213978662,
_destLongitude = 67.07555257166447;
Map<MarkerId, Marker> markers = {};
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();
String googleAPiKey = "AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow";

@override
void initState() {
super.initState();

/// origin marker
_addMarker(LatLng(_originLatitude, _originLongitude), "origin",
BitmapDescriptor.defaultMarker);

/// destination marker
_addMarker(LatLng(_destLatitude, _destLongitude), "destination",
BitmapDescriptor.defaultMarkerWithHue(90));
_getPolyline();
}

@override
Widget build(BuildContext context) {
return SafeArea(
child: Scaffold(
body: GoogleMap(
initialCameraPosition: CameraPosition(
target: LatLng(_originLatitude, _originLongitude), zoom: 15),
myLocationEnabled: true,
tiltGesturesEnabled: true,
compassEnabled: true,
scrollGesturesEnabled: true,
zoomGesturesEnabled: true,
onMapCreated: _onMapCreated,
markers: Set<Marker>.of(markers.values),
polylines: Set<Polyline>.of(polylines.values),
)),
);
}

void _onMapCreated(GoogleMapController controller) async {
mapController = controller;
}

_addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
MarkerId markerId = MarkerId(id);
Marker marker =
Marker(markerId: markerId, icon: descriptor, position: position);
markers[markerId] = marker;
}

_addPolyLine() {
PolylineId id = PolylineId("poly");
Polyline polyline = Polyline(
polylineId: id, color: Colors.red, points: polylineCoordinates);
polylines[id] = polyline;
setState(() {});
}

_getPolyline() async {
PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
googleAPiKey,
PointLatLng(24.7934, 67.1341),
PointLatLng(24.8617,67.0736),
travelMode: TravelMode.driving,
wayPoints: [PolylineWayPoint(location: "Gulshan-e-Iqbal,Karachi")]);
if (result.points.isNotEmpty) {
result.points.forEach((PointLatLng point) {
polylineCoordinates.add(LatLng(point.latitude, point.longitude));
});
}
_addPolyLine();
}
}