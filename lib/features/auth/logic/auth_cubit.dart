import 'dart:async';

import 'package:bloodinsight/features/auth/data/auth_state.dart';
import 'package:bloodinsight/features/user_profile/data/user_profile_model.dart';
import 'package:bloodinsight/shared/services/auth_service.dart';
import 'package:bloodinsight/shared/services/user_profile_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authService, required this.profileService})
      : super(authService.stateFromAuth) {
    _sub = authService.isSignedInStream.listen((isSignedIn) {
      emit(authService.stateFromAuth);
    });
  }

  final AuthService authService;
  final ProfileService profileService;
  StreamSubscription<bool>? _sub;

  String? get userId => authService.currentUser?.uid;

  Future<void> signInWithCredentials(String email, String password) async {
    emit(SigningInState(method: SignInMethod.email));

    try {
      final result = await authService.signInWithCredentials(email, password);

      switch (result) {
        case SignInResult.invalidEmail:
          emit(SignedOutState(error: 'This email address is invalid.'));
        case SignInResult.userDisabled:
          emit(SignedOutState(error: 'This user has been banned.'));
        case SignInResult.userNotFound:
          emit(
            SignedOutState(error: 'This user does not exist. Try signing up.'),
          );
        case SignInResult.wrongCredential:
          emit(SignedOutState(error: 'Invalid email or password.'));
        case SignInResult.success:
          emit(SignedInState(email: email));
      }
    } catch (err) {
      emit(SignedOutState(error: 'Unexpected error: $err'));
    }
  }

  Future<void> signUpWithCredentials(String email, String password) async {
    emit(SigningUpState());

    try {
      final result = await authService.signUpWithCredentials(email, password);

      switch (result) {
        case SignUpResult.emailAlreadyInUse:
          emit(SignedOutState(error: 'This email address is already in use.'));
        case SignUpResult.invalidEmail:
          emit(SignedOutState(error: 'This email address is invalid.'));
        case SignUpResult.operationNotAllowed:
          emit(
            SignedOutState(
              error:
                  'Email/password accounts are not enabled. Contact support.',
            ),
          );
        case SignUpResult.weakPassword:
          emit(SignedOutState(error: 'This password is too weak.'));
        case SignUpResult.success:
          emit(SignedUpState(email: email));
      }
    } catch (err) {
      emit(SignedOutState(error: 'Unexpected error: $err'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(SigningInState(method: SignInMethod.google));

    try {
      final result = await authService.signInWithGoogle();

      switch (result) {
        case SignInResult.userDisabled:
          emit(SignedOutState(error: 'This user has been banned.'));
        case SignInResult.userNotFound:
          emit(SignedOutState(error: 'Google sign in was cancelled.'));
        case SignInResult.success:
          {
            final profile =
                await profileService.getProfile(authService.currentUser!.uid);
            if (profile != null) {
              emit(SignedInState(email: authService.userEmail));
              return;
            }

            await profileService.upsertProfile(
              authService.currentUser!.uid,
              UserProfile(
                id: authService.currentUser!.uid,
                email: authService.userEmail,
                name: authService.currentUser!.displayName!.split(' ')[0],
                dateOfBirth:
                    DateTime.now().subtract(const Duration(days: 365 * 25)),
                gender: 'Male',
                height: 180,
                weight: 70,
                photoUrl: authService.currentUser!.photoURL,
              ),
            ); // Temporary solution
            emit(SignedInState(email: authService.userEmail));
          }
        default:
          emit(SignedOutState(error: 'An unexpected error occurred.'));
      }
    } catch (err) {
      emit(SignedOutState(error: 'Failed to sign in with Google: $err'));
    }
  }

  Future<void> signOut() async {
    await authService.signOut();

    emit(SignedOutState());
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

extension on AuthService {
  AuthState get stateFromAuth =>
      isSignedIn ? SignedInState(email: userEmail) : SignedOutState();
}
