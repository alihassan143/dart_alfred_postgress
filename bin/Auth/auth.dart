import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:path/path.dart';
import 'package:postgres/postgres.dart';

import '../server.dart';

class AuthHandler {
  static login(HttpRequest req, HttpResponse res) async {
    final body = await req.body as Map<String, dynamic>;
    final result = await loginUser(body["email"], body["password"]);
    if (result["error"] == true) {
      throw AlfredException(202, {"erro": "user  not exists"});
    } else {
      return result;
    }
  }

  static signup(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;

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
    if (result["error"] == true) {
      throw AlfredException(202, {"erro": "user  not exists"});
    } else {
      return result;
    }
  }
}

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  PostgreSQLResult? result;
  bool error = false;


  try {
    result = await connection.query(
        'SELECT * from users WHERE email =@email AND password=@password',
        substitutionValues: {"email": email, "password": password});
  } catch (_) {
    error = true;
  }



  if (error == true) {
    return {"error": true};
  } else if (result == null) {
    return {"error": true};
  } else if (result.isEmpty) {
    return {"error": true};
  } else {
    return {
      "error": false,
      "users": {
        "id": result.first[0],
        "name": result.first[1],
        "email": result.first[2],
        "image": result.first[4]
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
  PostgreSQLResult? result;
  bool error = false;


  try {
    await connection.query(
        ' INSERT INTO users(name,email,password,image) VALUES (@name,@email,@password,@image)',
        substitutionValues: {
          "name": name,
          "email": email,
          "password": password,
          "image": image
        });
  } on PostgreSQLException catch (e) {
    print(e.message);
    error = true;
  }
  try {
    result = await connection.query(
        'SELECT * from users WHERE email =@email AND password=@password',
        substitutionValues: {"email": email, "password": password});
  } on PostgreSQLException catch (e) {
    print(e.message);
    error = true;
  }


  if (error == true) {
    return {"error": true};
  } else if (result == null) {
    return {"error": true};
  } else if (result.isEmpty) {
    return {"error": true};
  } else {
    return {
      "error": false,
      "users": {
        "id": result.first[0],
        "name": result.first[1],
        "email": result.first[2],
        "image": result.first[4]
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
