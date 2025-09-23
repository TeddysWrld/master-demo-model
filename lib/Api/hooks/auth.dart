import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:master_demo_app/Api/firebase-config.dart';

/// Create user with email and password
Future<UserCredential> doCreateUserWithEmailAndPassword(String email, String password) {
    return auth.createUserWithEmailAndPassword(email: email, password: password);
}

/// Sign in with email and password
Future<UserCredential> doSignInWithEmailAndPassword(String email, String password) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
}

/// Sign in with Google
Future<UserCredential?> doSignInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn(clientId: '979285665506-bgabd0vtkc52ue0abu8r7vqkn89dooee.apps.googleusercontent.com').signIn();
    if (googleUser == null) return null; // User cancelled
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
    );
    return await auth.signInWithCredential(credential);
}

/// Sign out
Future<void> doSignOut() {
    return auth.signOut();
}

/// Send password reset email
Future<void> doPasswordReset(String email) {
    return auth.sendPasswordResetEmail(email: email);
}

/// Change password (user must be signed in)
Future<void> doPasswordChange(String newPassword) async {
    final user = auth.currentUser;
    if (user != null) {
        await user.updatePassword(newPassword);
    } else {
        throw FirebaseAuthException(code: 'no-current-user', message: 'No user is currently signed in.');
    }
}

/// Send email verification (user must be signed in)
Future<void> doSendEmailVerification() async {
    final user = auth.currentUser;
    if (user != null) {
        await user.sendEmailVerification();
    } else {
        throw FirebaseAuthException(code: 'no-current-user', message: 'No user is currently signed in.');
    }
}