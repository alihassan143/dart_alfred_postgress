import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:encrypt/encrypt.dart';
import 'package:postgres/postgres.dart';

//create directory in the server
final directory = Directory("ApplicationFiles");
//initialize the alfred server
final app = Alfred();
//password encryption algrothim
final key = Key.fromSecureRandom(32);
final iv = IV.fromSecureRandom(16);
final encrypter = Encrypter(AES(key));

//use to connect the postgress server
final connection = PostgreSQLConnection("localhost", 5432, "postgres",
    username: "postgres", password: "123456");
