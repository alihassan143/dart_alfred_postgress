import 'dart:io';

import 'package:alfred/alfred.dart';

import 'package:path/path.dart';

import '../constants.dart';

import 'postgress.dart';

class AuthHandler {
  static login(HttpRequest req, HttpResponse res) async {
    final body = await req.body as Map<String, dynamic>;
    bool emailExists = await PostGressAuth().checkEmail(body["email"]);
    if (emailExists == true) {
      final result =
          await PostGressAuth().loginUser(body["email"], body["password"]);

      return result;
    } else {
      throw AlfredException(400, {"error": "user  not exists"});
    }
  }

  static signup(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;
    bool emailExists = await PostGressAuth().checkEmail(body["email"]);
    if (emailExists == false) {
      // Create the upload directory if it doesn't exist
      if (await directory.exists() == false) {
        await directory.create();
      }

      // Get the uploaded file content
      final uploadedFile = (body['image'] as HttpBodyFileUpload);
      var fileBytes = (uploadedFile.content as List<int>);

      // Create the local file name and save the file
      await File(join('${directory.path}/${uploadedFile.filename}'))
          .writeAsBytes(fileBytes);

      final result = await PostGressAuth().signupSave(
          body["email"],
          body["password"],
          body['name'],
          "http://localhost:${req.headers.port}/images/" +
              join('/${uploadedFile.filename}'));

      return result;
    } else {
      throw AlfredException(400, {"error": "email already exists"});
    }
  }

  static sendOtpTOEmail(HttpRequest req, HttpResponse res) async {
    final body = await req.body as Map<String, dynamic>;
    bool emailExists = await PostGressAuth().checkEmail(body["email"]);
    if (emailExists == true) {
      final result = await PostGressAuth().sendOtpTOEmail(body["email"]);
      return result;
    } else {
      throw AlfredException(400, {"error": "email  not exists"});
    }
  }

  // static verifyEmailOtp(HttpRequest req, HttpResponse res) async {
  //   final body = await req.body as Map<String, dynamic>;
  //   bool emailExists = await PostGressAuth().checkEmail(body["email"]);
  //   if (emailExists == true) {
  //     final result =
  //         await PostGressAuth().verifyEmail(body["email"], body["password"]);
  //     if (result == true) {
  //       return {"error": false, "message": "otp is verified"};
  //     }
  //   } else {
  //     throw AlfredException(400, {"error": "email  not exists"});
  //   }
  // }

  static updatePassword(HttpRequest req, HttpResponse res) async {
    final body = await req.body as Map<String, dynamic>;
    bool emailExists = await PostGressAuth().checkEmail(body["email"]);
    if (emailExists == true) {
      final result =
          await PostGressAuth().updatePassword(body["email"], body["password"]);

      return result;
    } else {
      throw AlfredException(400, {"error": "email  not correcr"});
    }
  }
}
