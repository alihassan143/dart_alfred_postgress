import 'dart:io';
import 'package:args/args.dart';

import 'Routes/apiroutes.dart';
import 'constants.dart';

void main(List<String> arguments) async {
  var parser = ArgParser()..addOption("port", abbr: "p");
  var result = parser.parse(arguments);
  var portStr = result["port"] ?? Platform.environment["PORT"] ?? "8080";
  var port = int.parse(portStr);
  // ignore: unnecessary_null_comparison
  if (port == null) {
    stdout.writeln("Could not parse port value $portStr into a number.");
    exitCode = 64;
    return;
  }

  await connection.open().then((value) => print("database connected"));
  ApiRoutes().alfedRoutes();

  await app.listen(port);
}
