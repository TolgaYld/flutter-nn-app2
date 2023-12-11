import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn(
      clientId:
          "319605135457-fdeep9gd39g652nvn2lbmdhb2n3003e1.apps.googleusercontent.com");

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
}
