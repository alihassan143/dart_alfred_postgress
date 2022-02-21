import 'dart:io';

import 'package:alfred/alfred.dart';

import 'package:path/path.dart';
import 'package:postgres/postgres.dart';

import '../server.dart';

class AuthHandler {
  static login(HttpRequest req, HttpResponse res) async {
    final body = await req.body as Map<String, dynamic>;
    bool emailExists = await checkEmail(body["email"]);
    if (emailExists == true) {
      final result = await loginUser(body["email"], body["password"]);

      return result;
    } else {
      throw AlfredException(400, {"error": "user  not exists"});
    }
  }

  static signup(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;
    bool emailExists = await checkEmail(body["email"]);
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

      final result = await signupSave(
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
}

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
    throw AlfredException(400, {"error": true, "message": "cannot find user"});
  } else if (result.isEmpty) {
    throw AlfredException(400, {"error": true, "message": "cannot find user"});
  } else {
    return {
      "error": false,
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
    throw AlfredException(401, {"error": true, "message": "some error occur"});
  } else if (result == null) {
    throw AlfredException(402, {"error": true, "message": "some error occur"});
  } else if (result.isEmpty) {
    throw AlfredException(403, {"error": true, "message": "some error occur"});
  } else if (usererror) {
    throw AlfredException(400, {"error": true, "message": "some error occur"});
  } else {
    return {
      "error": false,
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
