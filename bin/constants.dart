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
final connection = PostgreSQLConnection(
  "ec2-63-32-7-190.eu-west-1.compute.amazonaws.com",
  5432,
  "da60sh8r0bc1on",
  username: "vlvtdlcajnrkai",
  password: "440fff10b00807d81448ad3f2ec060508b08299f5c88aaa48b1c4a830d89cda5",
  useSSL: true
);
