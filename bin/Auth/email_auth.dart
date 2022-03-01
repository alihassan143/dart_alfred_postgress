import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class VerifyEmail {
  Future<bool> sendOtpToEmail(String otp, String useremail) async {
    final username =
        'postmaster@sandbox81f1707d34164a5a966a0a25585927dc.mailgun.org';
    final password = "944c14b129cf1d936efb4bd38e55b7ad-e2e3d8ec-f3ce3a7c";

    final smtpServer = SmtpServer('smtp.mailgun.org',
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
      print(sendReport.toString());
      statusCode = HttpStatus.ok;

      return true;
    } on MailerException catch (e) {
      print('Message not sent: ${e.message}');
      throw AlfredException(404, {"message": "error occur"});
    }
  }
}
