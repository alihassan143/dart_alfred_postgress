import 'dart:convert';
import 'dart:io';

import 'package:alfred/alfred.dart';

class VerifyEmail {
  Future<Map<String, dynamic>> sendOtpToEmail(String useremail) async {
    var client = HttpClient();
    try {
      var url =
          "https://app-authenticator.herokuapp.com/dart/auth/$useremail?CompanyName=alihassan";

      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close();
      var data = await response.transform(utf8.decoder).join();
      Map<String, dynamic> body = jsonDecode(data);
      return body;
    } catch (_) {
      print(_);
      throw AlfredException(
          404, {"error": true, "message": "send email error"});
    }
  }
}
