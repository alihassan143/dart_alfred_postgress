import 'package:alfred/alfred.dart';

import '../Secrets/token.dart';

class ApiMiddleWare {
  //applied middle ware for authentic email
  //
  static applicationMiddelWare(HttpRequest req, HttpResponse res) {
    if (req.headers.value('Authorization') != null) {
      String token = req.headers.value('Authorization')!;
      final parts = token.split(' ');
      final resutl = CreateToken().isValidToken(parts[1]);
      // Do work
      if (resutl == false) {
        throw AlfredException(401, {'message': 'authentication failed'});
      }
    } else {
      throw AlfredException(401, {'message': 'authentication failed'});
    }
  }
}
