import 'dart:io';

import 'package:alfred/alfred.dart';

import 'package:path/path.dart';

import '../Secrets/token.dart';
import '../constants.dart';

import 'postgress.dart';

class AuthHandler {
  //api route for login request
  static login(HttpRequest req, HttpResponse res) async {
    //it accepts the raw json data
    final body = await req.body as Map<String, dynamic>;
    //this check that email is exits in the database or not

    bool emailExists = await PostGressAuth().checkEmail(body["email"]);
    if (emailExists == true) {
      //this request the databse the fetch the existing user data if exists it returns the data otherwise exception will return
      final result =
          await PostGressAuth().loginUser(body["email"], body["password"]);

      return result;
    } else {
      throw AlfredException(400, {"error": "user  not exists"});
    }
  }
  //sign up api route

  static signup(HttpRequest req, HttpResponse res) async {
    print(req.headers.host);
    //it is form data api it accepts all the api data in form
    final body = await req.bodyAsJsonMap;
    //check if use exists or not
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
//create the user data and return data that is save as json
      final result = await PostGressAuth().signupSave(
          body["email"],
          body["password"],
          body['name'],
          "https://${req.headers.host}/images/" +
              join('/${uploadedFile.filename}'));

      return result;
    } else {
      throw AlfredException(400, {"error": "email already exists"});
    }
  }

//
  static sendOtpTOEmail(HttpRequest req, HttpResponse res) async {
    //it accept the json
    final body = await req.body as Map<String, dynamic>;
    //chech user exists or not
    bool emailExists = await PostGressAuth().checkEmail(body["email"]);
    if (emailExists == true) {
      //return the token and otp to be veirfied
      final result = await PostGressAuth().sendOtpTOEmail(body["email"]);
      return result;
    } else {
      throw AlfredException(400, {"error": "email  not exists"});
    }
  }

  static verifyEmailOtp(HttpRequest req, HttpResponse res) async {
    final body = await req.body as Map<String, dynamic>;
    String token = req.headers.value('Authorization')!;
    final parts = token.split(' ')[1];

    final result = CreateToken().forgotPasswordTokenVerification(parts);
    return await PostGressAuth().verifyOtpWithEmail(result, body["otp"]);
  }

//api route for update the exiting user who forgot the password
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
