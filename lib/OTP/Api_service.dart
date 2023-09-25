import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/OTP_response.dart';
import 'config.dart';

//final apiService = Provider((ref) => APIService());

class APIService {

  static var client = http.Client();

  static Future<OtpLoginResponseModel> otpLogin(String mobileNO) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.otpLoginAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode({"phone": mobileNO}),
    );

    return otploginResponseJson(response.body);
  }

  static Future<OtpLoginResponseModel> verifyOTP(
      String mobileNo,
      String otpHash,
      String otpCode,
      ) async {
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    var url = Uri.http(Config.apiURL, Config.otpVerifyAPI);

    var response = await client.post(
      url,
      headers: requestHeaders,
      body: jsonEncode({"phone": mobileNo, "otp": otpCode, "hash": otpHash}),
    );

    return otploginResponseJson(response.body);
  }
}