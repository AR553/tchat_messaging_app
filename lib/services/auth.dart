import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tchat_messaging_app/utilities/snack_bar.dart';

import 'firestore.dart';

class Authentication {
  static Future<User> signInWithGoogle({@required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user;
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential = await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential = await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            CustomSnackBar.show(context, content: 'The account already exists with a different credential');
          } else if (e.code == 'invalid-credential') {
            CustomSnackBar.show(context, content: 'Error occurred while accessing credentials. Try again.');
          }
        } catch (e) {
          CustomSnackBar.show(context, content: 'Error occurred using Google Sign In. Try again.');
        }
      }
    }
    return user;
  }

  static Future<void> signOut({@required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      Firestore.updateUserPresence(false);
      if (!kIsWeb) {
        await googleSignIn.signOut();
        print('Signed out');
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      CustomSnackBar.show(
        context,
        content: 'Error signing out. Try again.',
      );
    }
  }
}
