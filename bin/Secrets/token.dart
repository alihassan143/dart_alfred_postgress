// import 'package:jaguar_jwt/jaguar_jwt.dart';

import 'package:alfred/alfred.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'secret.dart';

class CreateToken {
  //that create token for the middle wares so authenticated request will be able to do work
  // String createToken(String id) {
  //   final claimSet = JwtClaim(
  //       issuer: 'Ali Hassan',
  //       subject: id,
  //       issuedAt: DateTime.now(),
  //       maxAge: const Duration(hours: 12));
  //   String secret = SercretOfserver.secret;
  //   return issueJwtHS256(claimSet, secret);
  // }
  String createToken(String id) {
    final jwt = JWT({}, issuer: 'Ali Hassan', jwtId: id);
    String token = jwt.sign(SecretKey(SercretOfserver.secret),
        expiresIn: Duration(days: 3));
    return token;
  } //check the toke generated by the algorthm is valid or not
  // bool isValidToken(String token) {
  //   String secret = SercretOfserver.secret;

  //   try {
  //     verifyJwtHS256Signature(token, secret);

  //     return true;
  //   } on JwtException catch (_) {
  //     return false;
  //   }
  // }
  String createForgetPasswordToken(String id, ) {
    final jwt = JWT({"userid":id}, issuer: 'Ali Hassan', jwtId: id);
    String token = jwt.sign(SecretKey(SercretOfserver.secret),
        expiresIn: Duration(minutes: 30));
    return token;
  }

  String forgotPasswordTokenVerification(String token) {
    try {
      // Verify a token
      final jwt = JWT.verify(token, SecretKey(SercretOfserver.secret));
      // print(jwt.payload);
      return jwt.payload["userid"];
    } on JWTExpiredError {
      throw AlfredException(
          400, {"error": true, "message": "your token time is expired"});
    } on JWTError catch (_) {
      throw AlfredException(
          400, {"error": true, "message": "token validation failed"});
    } on FormatException catch (e) {
      throw AlfredException(400, {"error": true, "message": e.message});
    }
  }

  bool isValidToken(String token) {
    try {
      // Verify a token
      JWT.verify(token, SecretKey(SercretOfserver.secret));

      return true;
    } on JWTExpiredError {
      return false;
    } on JWTError catch (_) {
      return false; // ex: invalid signature
    }
  }
}
