import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum SignInResult {
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongCredential,
  success,
}

enum SignUpResult {
  emailAlreadyInUse,
  invalidEmail,
  operationNotAllowed,
  weakPassword,
  success,
}

class AuthService {
  AuthService({required this.firebaseAuth});

  final FirebaseAuth firebaseAuth;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isSignedIn => currentUser != null;

  Stream<bool> get isSignedInStream =>
      firebaseAuth.userChanges().map((user) => user != null);

  String get userEmail => currentUser!.email!;

  User? get currentUser => firebaseAuth.currentUser;

  Future<SignInResult> signInWithCredentials(
    String email,
    String password,
  ) async {
    try {
      if (isSignedIn) {
        await firebaseAuth.signOut();
      }

      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return SignInResult.invalidEmail;
        case 'user-disabled':
          return SignInResult.userDisabled;
        case 'user-not-found':
          return SignInResult.userNotFound;
        case 'invalid-credential':
          return SignInResult.wrongCredential;
        default:
          rethrow;
      }
    }
  }

  Future<SignUpResult> signUpWithCredentials(
    String email,
    String password,
  ) async {
    try {
      if (isSignedIn) {
        await firebaseAuth.signOut();
      }

      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return SignUpResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return SignUpResult.emailAlreadyInUse;
        case 'invalid-email':
          return SignUpResult.invalidEmail;
        case 'operation-not-allowed':
          return SignUpResult.operationNotAllowed;
        case 'weak-password':
          return SignUpResult.weakPassword;
        default:
          rethrow;
      }
    }
  }

  Future<SignInResult> signInWithGoogle() async {
    try {
      if (isSignedIn) {
        await firebaseAuth.signOut();
      }

      // Trigger Google Sign In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return SignInResult.userNotFound;
      }

      // Get auth details from Google Sign In
      final googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      await firebaseAuth.signInWithCredential(credential);
      return SignInResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-disabled':
          return SignInResult.userDisabled;
        default:
          rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() => firebaseAuth.signOut();
}
