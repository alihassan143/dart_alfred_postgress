import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:encrypt/encrypt.dart';
import 'package:postgres/postgres.dart';

final directory = Directory("ApplicationFiles");
final app = Alfred();
  final key = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));
    final connection = PostgreSQLConnection("localhost", 5432, "postgres",
    username: "postgres", password: "123456");