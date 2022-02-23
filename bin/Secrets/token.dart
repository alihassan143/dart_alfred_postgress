import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'secret.dart';

class CreateToken {
  String createToken(String id) {
    final claimSet = JwtClaim(
        issuer: 'Ali Hassan',
        subject: id,
        issuedAt: DateTime.now(),
        maxAge: const Duration(hours: 12));
    String secret = SercretOfserver.secret;
    return issueJwtHS256(claimSet, secret);
  }

  bool isValidToken(String token) {
    String secret = SercretOfserver.secret;

    try {
      verifyJwtHS256Signature(token, secret);

      return true;
    } on JwtException catch (_) {
      return false;
    }
  }
}
