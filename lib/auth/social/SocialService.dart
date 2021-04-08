
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FacebookLogin fbLogin = FacebookLogin();
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
    clientId: "",
    hostedDomain: "",
  );
  // Determine if Apple SignIn is available
  Future<bool> get appleSignInAvailable => SignInWithApple.isAvailable();

  /// Sign in with Apple
  Future<User> appleSignIn() async {
    var redirectURL = "https://stoppoint.com/callbacks/sign_in_with_apple";
    var clientID = "NBQ364D32Q";
    try {

      final AuthorizationCredentialAppleID appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,

        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
      );
      final UserCredential authResult =
      await _auth.signInWithCredential(credential);
      final User user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
      Map<String, dynamic> decodedToken = JwtDecoder.decode( appleIdCredential.identityToken);
      user.updateEmail(decodedToken["email"]);
      user.updateProfile(displayName:  decodedToken["email"].split('@')[0]);
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount == null) {
      return null;
    }
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    return user;
  }

  Future<User> signInWithFacebook() async {
    final FacebookLoginResult _facebookLogin =
        await fbLogin.logIn(['email', 'public_profile']);

    if (_facebookLogin.status != FacebookLoginStatus.loggedIn) {
      return null;
    }
//  accessToken: _facebookLogin.accessToken.token
    final AuthCredential credential =
        FacebookAuthProvider.credential(_facebookLogin.accessToken.token);

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    return user;
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }

  void signOutFacebook() async {
    await fbLogin.logOut();

    print("User Sign Out");
  }

  void logOut() async {
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    } else {
      await fbLogin.logOut();
    }
  }
}
