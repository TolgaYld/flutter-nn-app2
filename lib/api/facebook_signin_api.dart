import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookSignInApi {
  static final _facebookSignIn = FacebookAuth.i.login(
    permissions: [
      'public_profile',
      'email',
    ],
  );

  static Future<LoginResult?> login() async => await _facebookSignIn;
}
