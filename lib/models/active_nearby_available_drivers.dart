class ActiveNearbyAvailableDrivers
{
  String? driverId;
  double? locationLatitude;
  double? locationLongitude;

  ActiveNearbyAvailableDrivers({
    this.driverId,
    this.locationLatitude,
    this.locationLongitude,
  });

  ActiveNearbyAvailableDrivers.fromJson(Map<dynamic, dynamic> json)
  {
    driverId = json['driver_id'];
    locationLatitude = json['location_latitude'];
    locationLongitude = json['location_longitude'];
  }
}