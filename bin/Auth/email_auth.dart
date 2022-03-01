import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class VerifyEmail {
  Future<bool> sendOtpToEmail(String otp, String useremail) async {
    print("here");
    final username = 'apikey';
    final password =
        "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";

    final smtpServer = SmtpServer(
      'smtp.sendgrid.net',
      port: 25,
      username: username,
      password: password,
    );

    final message = Message()
      ..from = Address(username, 'Ali Hassan')
      ..recipients.add("alihassan143cool@gmail.com")
      ..subject = 'New POST message from user'
      ..text = "Your email verification otp code is $otp";
    int statusCode;
    try {
      print("email is send");
      final sendReport = await send(message, smtpServer);
      print(sendReport.toString());
      statusCode = HttpStatus.ok;

      return true;
    } on MailerException catch (e) {
      print('Message not sent: ${e.message}');
      throw AlfredException(404, {"message": "error occur"});
    }
  }
}
