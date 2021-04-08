
// import 'package:corsac_jwt/corsac_jwt.dart';

import 'package:jaguar_jwt/jaguar_jwt.dart';

class JWTHelper {

  String getIdFromToken (String token ) {
    try {
      final JwtClaim decClaimSet = verifyJwtHS256Signature(token, 'secretKey');

      if (decClaimSet.containsKey('userId')) {
        final v = decClaimSet['userId'];
          if (v is String) {
            return v;
          }
      }

    } on JwtException {}
  }


}