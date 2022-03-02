import 'package:alfred/alfred.dart';
import 'package:otp/otp.dart';

import 'package:postgres/postgres.dart';

import '../Secrets/token.dart';
import '../constants.dart';
import 'email_auth.dart';

class PostGressAuth {
  //login user to return the user data from the database
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    PostgreSQLResult? result;
    final encryptedPasswrod = encrypter.encrypt(password, iv: iv);
    bool error = false;

    try {
      result = await connection.query(
          'SELECT * from users WHERE email =@email AND password=@password',
          substitutionValues: {
            "email": email,
            "password": encryptedPasswrod.base16
          });
    } catch (_) {
      error = true;
    }

    if (error == true) {
      throw AlfredException(
          400, {"error": true, "message": "email or password in incorrect"});
    } else if (result == null) {
      throw AlfredException(
          400, {"error": true, "message": "cannot find user"});
    } else if (result.isEmpty) {
      throw AlfredException(
          400, {"error": true, "message": "cannot find user"});
    } else {
      return {
        "error": false,
        "token": CreateToken().createToken(result.first[0]),
        "users": {
          "id": result.first[0],
          "name": result.first[1],
          "email": result.first[2],
          "image": result.first[4],
          "created_at": result.first[5]
        }
      };
    }
    // await connection.query('''
    //   INSERT INTO customers (name,email,address,country)
    //   VALUES ('Jermaine Oppong','jermaine@oppong.co','1212 Some Street','United Kingdom')
    // ''');
    // var results = await connection.query('SELECT * from customers WHERE id=4');

    // for (var row in results) {
    //   print('''

    //   id: ${row[0]}
    //   name: ${row[1]}
    //   email: ${row[2]}
    //   address: ${row[3]}
    //   country: ${row[4]}

    //   ''');
    // }
  }
  //that is used to save the user data is postgress sql server

  Future<Map<String, dynamic>> signupSave(
      String email, String password, String name, String image) async {
    final encryptedPasswrod = encrypter.encrypt(password, iv: iv);
    PostgreSQLResult? result;
    bool error = false;
    bool usererror = false;

    try {
      await connection.query(
          ' INSERT INTO users(name,email,password,image,created_at) VALUES (@name,@email,@password,@image,@created_at)',
          substitutionValues: {
            "name": name,
            "email": email,
            "password": encryptedPasswrod.base16,
            "image": image,
            "created_at": DateTime.now().toIso8601String()
          });
    } on PostgreSQLException catch (_) {
      error = true;
    }
    try {
      result = await connection.query(
          'SELECT * from users WHERE email =@email AND password=@password',
          substitutionValues: {
            "email": email,
            "password": encryptedPasswrod.base16
          });
    } on PostgreSQLException catch (_) {
      usererror = true;
    }

    if (error == true) {
      throw AlfredException(
          401, {"error": true, "message": "some error occur"});
    } else if (result == null) {
      throw AlfredException(
          402, {"error": true, "message": "some error occur"});
    } else if (result.isEmpty) {
      throw AlfredException(
          403, {"error": true, "message": "some error occur"});
    } else if (usererror) {
      throw AlfredException(
          400, {"error": true, "message": "some error occur"});
    } else {
      return {
        "error": false,
        "token": CreateToken().createToken(result.first[0]),
        "users": {
          "id": result.first[0],
          "name": result.first[1],
          "email": result.first[2],
          "image": result.first[4],
          "created_at": result.first[5]
        }
      };
    }

    // await connection.query('''
    //   INSERT INTO customers (name,email,address,country)
    //   VALUES ('Jermaine Oppong','jermaine@oppong.co','1212 Some Street','United Kingdom')
    // ''');
    // var results = await connection.query('SELECT * from customers WHERE id=4');

    // for (var row in results) {
    //   print('''

    //   id: ${row[0]}
    //   name: ${row[1]}
    //   email: ${row[2]}
    //   address: ${row[3]}
    //   country: ${row[4]}

    //   ''');
    // }
  }

//update existing user password
  Future<Map<String, dynamic>> updatePassword(
      String email, String password) async {
    final encryptedPasswrod = encrypter.encrypt(password, iv: iv);
    bool error = false;

    try {
      await connection.query(
          'UPDATE users SET password =@password WHERE email =@email',
          substitutionValues: {
            "email": email,
            "password": encryptedPasswrod.base16
          });
    } catch (_) {
      error = true;
    }

    if (error == true) {
      throw AlfredException(
          400, {"error": true, "message": "email or password in incorrect"});
    } else {
      return {"error": false, "message": "password reset successfull"};
    }
    // await connection.query('''
    //   INSERT INTO customers (name,email,address,country)
    //   VALUES ('Jermaine Oppong','jermaine@oppong.co','1212 Some Street','United Kingdom')
    // ''');
    // var results = await connection.query('SELECT * from customers WHERE id=4');

    // for (var row in results) {
    //   print('''

    //   id: ${row[0]}
    //   name: ${row[1]}
    //   email: ${row[2]}
    //   address: ${row[3]}
    //   country: ${row[4]}

    //   ''');
    // }
  }

//that generate the otp return the generated otp so the app verifies the otp currently it did not send the otp to email it will be implemented in the future
  Future<Map<String, dynamic>> sendOtpTOEmail(String email) async {
    Map<String, dynamic> data = await emailId(email);
    String otp = OTP.generateTOTPCodeString(
        'JBSWY3DPEHPK3PXP', DateTime.now().millisecondsSinceEpoch);
    print("now here");
    try {
      await VerifyEmail().sendOtpToEmail(otp, email);

      return {
        "success": true,
        "token": CreateToken().createForgetPasswordToken(data["id"], otp),
        "message": "otp send successfull"
      };
    } catch (_) {
      return {
        "success": true,
        "token": CreateToken().createForgetPasswordToken(data["id"], otp),
        "message": "otp send unsuccessfull",
        "otp": otp
      };
    }
  }

  // Future<bool> verifyEmail(String email, String otp) async {
  //   EmailAuth emailAuth = EmailAuth(
  //     sessionName: "Sample session",
  //   );
  //   try {
  //     bool result = emailAuth.validateOtp(recipientMail: email, userOtp: otp);
  //     if (result == true) {
  //       return true;
  //     } else {
  //       throw AlfredException(
  //           400, {"error": true, "message": "Otp is not correct"});
  //     }
  //   } catch (_) {
  //     throw AlfredException(
  //         400, {"error": true, "message": "Some Error Occur"});
  //   }
  // }
//check that email exists or not in the database
  Future<bool> checkEmail(String email) async {
    PostgreSQLResult? result;
    try {
      result = await connection.query('SELECT * from users WHERE email =@email',
          substitutionValues: {"email": email});
      if (result.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on PostgreSQLException catch (_) {
      return false;
    }
  }

//that return the database generated user id so the token can be generated against that user
  Future<Map<String, dynamic>> emailId(String email) async {
    PostgreSQLResult? result;
    try {
      result = await connection.query('SELECT * from users WHERE email =@email',
          substitutionValues: {"email": email});
      if (result.isNotEmpty) {
        return {
          "id": result.first[0],
          "exists": true,
        };
      } else {
        throw AlfredException(
            400, {"error": true, "message": "email not correct"});
      }
    } on PostgreSQLException catch (_) {
      throw AlfredException(
          400, {"error": true, "message": "email not correct"});
    }
  }
}
