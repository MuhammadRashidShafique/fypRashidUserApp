class BookingModel {
  String bookingID;
  String dateBooked;
  String driverID;
  String driverName;
  String driverPhone;
  int farePrice;
  bool isDaily;
  String passengerID;
  String passengerName;
  String passengerPhone;
  String scheduleID;
  int seatsBooked;
  String selectedStop;
  String status;
  String passengerStatus;
  String timeBooked; // Add the timeBooked field

  BookingModel({
    required this.bookingID,
    required this.dateBooked,
    required this.driverID,
    required this.driverName,
    required this.driverPhone,
    required this.farePrice,
    required this.isDaily,
    required this.passengerID,
    required this.passengerName,
    required this.passengerPhone,
    required this.scheduleID,
    required this.seatsBooked,
    required this.selectedStop,
    required this.status,
    required this.timeBooked,
    required this.passengerStatus// Add the timeBooked field
  });

  factory BookingModel.fromMap(String bookingID, Map<dynamic, dynamic> map) {
    return BookingModel(
      bookingID: bookingID,
      dateBooked: map['dateBooked'] ?? '',
      driverID: map['driver_id'] ?? '',
      driverName: map['driver_name'] ?? '',
      driverPhone: map['driver_phone'] ?? '',
      farePrice: int.tryParse(map['farePrice'].toString()) ?? 0,
      isDaily: map['isDaily'] == 'true',
      passengerID: map['passenger_id'] ?? '',
      passengerName: map['passenger_name'] ?? '',
      passengerPhone: map['passenger_phone'] ?? '',
      scheduleID: map['scheduleID'] ?? '',
      seatsBooked: int.tryParse(map['seatsBooked'].toString()) ?? 0,
      selectedStop: map['selectedStop'] ?? '',
      status: map['status'] ?? '',
      timeBooked: map['timeBooked'] ?? '',
      passengerStatus: map["passenger_status"] ?? '',
    );
  }
}
