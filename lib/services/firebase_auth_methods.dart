import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:see_gas_app/providers/auth_state_notifier.dart';
import 'package:see_gas_app/utils/firebase_fields.dart';

import '../features/authentication/entities/auth_result.dart';
import '../models/user_model.dart';
import '../providers/user_notifier.dart';
import '../utils/typedefs.dart';
import 'firebase_firestore_methods.dart';
import 'firebase_storage_methods.dart';

class FirebaseAuthMethods {
  final Ref ref;
  final FirebaseAuth _auth;

  FirebaseAuthMethods(this.ref, this._auth);

  User? get currentUser => _auth.currentUser;

  Future<AuthResult> signUp({
    required String email,
    required String username,
    required String password,
    required String contact,
    Uint8List? file,
  }) async {
    try {
      final result = await FirestoreMethods().getUser(email: email);
      if (result.docs.isEmpty) {
         await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final photoLink = await FirebaseStorageMethods().uploadPicture(
          file: file,
          userId: _auth.currentUser?.uid ?? "",
        );
        final List<String> providerData = ['password'];
        final userModel =UserModel(
          username: username,
          userId: _auth.currentUser?.uid,
          email: email,
          photoLink: photoLink,
          phoneContact: contact,
          devices: [],
        );
        await FirestoreMethods().storeUserInfo(
            user: userModel,
            provider: providerData);
         await ref.read(userProvider.notifier).cacheUser(userModel);

        return AuthResult.success;
      } else {
        ref.watch(errorMessageProvider.notifier).setError(
            "Email already exists. Consider Signing in or Using Google");
        return AuthResult.aborted;
      }
    } on FirebaseAuthException catch (e) {
      if (e.message ==
          "The email address is already in use by another account.") {
        ref.read(errorMessageProvider.notifier).setError(
            "Email already exists. Consider Signing in or Using Google");
        return AuthResult.aborted;
      }
      ref.watch(errorMessageProvider.notifier).setError();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();

    if (googleAccount == null) {
      return AuthResult.aborted;
    }

    final googleAuth = await googleAccount.authentication;
    final authCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      await _auth.signInWithCredential(authCredential);
      return AuthResult.success;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e.code);
      }
      ref.watch(errorMessageProvider.notifier).setError();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      ref.watch(errorMessageProvider.notifier).setError("Empty Credentials");
      return AuthResult.aborted;
    }
    final authCredential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    try {
      await _auth.signInWithCredential(authCredential);
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e.message);
      }
      ref.watch(errorMessageProvider.notifier).setError(
          "Invalid Login Credentials. Consider Google or Recover Password");
      return AuthResult.failure;
    }
  }

  Future<AuthResult> sendVerificationMail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return AuthResult.success;
    } on Exception {
      ref.watch(errorMessageProvider.notifier).setError();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      return AuthResult.success;
    } on Exception {
      ref.watch(errorMessageProvider.notifier).setError();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> linkWithEmailPassword(
      {required String email, required String password}) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        AuthCredential emailCredential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await currentUser.linkWithCredential(emailCredential);
        if (kDebugMode) {
          print('Successfully linked Email/Password with Google account');
        }
        return AuthResult.success;
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print('Failed to link accounts: $e');
        }
        if (e.code == 'wrong-password') {
          ref.watch(errorMessageProvider.notifier).setError();

          return AuthResult.incorrect;
        }
        ref.watch(errorMessageProvider.notifier).setError();

        return AuthResult.failure;
      }
    }
    ref.watch(errorMessageProvider.notifier).setError();

    return AuthResult.failure;
  }

  Future<AuthResult> resetPassword({required String email}) async {
    try {
      final providerData =
          await FirestoreMethods().getProviderData(email: email);

      if (providerData.contains('password')) {
        await _auth.sendPasswordResetEmail(email: email);
        return AuthResult.success;
      } else if (providerData.contains('google.com')) {
        ref.watch(errorMessageProvider.notifier).setError(
            'This account is linked with Google Sign-in. Please use Google to sign in.');
        return AuthResult.failure;
      } else if (providerData.isEmpty) {
        ref
            .watch(errorMessageProvider.notifier)
            .setError('This email is not registered');
        return AuthResult.failure;
      } else {
        ref
            .watch(errorMessageProvider.notifier)
            .setError('This account is registered with another provider.');
        return AuthResult.failure;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        ref
            .watch(errorMessageProvider.notifier)
            .setError('The email format is invalid.');
        return AuthResult.failure;
      } else if (e.code == 'user-not-found') {
        ref
            .watch(errorMessageProvider.notifier)
            .setError('This email is not registered.');
        return AuthResult.failure;
      }
      ref
          .watch(errorMessageProvider.notifier)
          .setError('An error occurred: ${e.message}');
      return AuthResult.failure;
    } catch (e) {
      ref.watch(errorMessageProvider.notifier).setError();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();

      return AuthResult.success;
    } on Exception {
      ref.watch(errorMessageProvider.notifier).setError();
      return AuthResult.failure;
    }
  }

  Future<AuthResult> deleteUser({required UserId userId}) async {
    try {
      await FirebaseFirestore.instance
          .collection(FirebaseFields.users)
          .doc(userId)
          .delete();
      await _auth.currentUser?.delete();

      return AuthResult.success;
    } on Exception {
      ref.watch(errorMessageProvider.notifier).setError();
      return AuthResult.failure;
    }
  }

  bool get isLoggedIn => _auth.currentUser?.uid != null;

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  String? get email => _auth.currentUser?.email;
}
