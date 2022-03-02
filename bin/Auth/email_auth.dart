import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class VerifyEmail {
  Future<bool> sendOtpToEmail(String otp, String useremail) async {
    final username = 'alihassan143test@gmail.com';
    final password = "";

    final smtpServer = SmtpServer('smtp-relay.sendinblue.com',
        ssl: false,
        port: 587,
        username: username,
        password: password,
        allowInsecure: true);

    final message = Message()
      ..from = Address(username, 'Ali Hassan')
      ..recipients.add("alihassan143cool@gmail.com")
      ..subject = 'New POST message from user'
      ..text = "Your email verification otp code is $otp";
    int statusCode;
    try {
      final sendReport = await send(message, smtpServer);

      statusCode = HttpStatus.ok;

      return true;
    } on MailerException catch (e) {
      print('Message not sent: ${e.message}');
      throw AlfredException(404, {"message": "error occur"});
    }
  }
}
