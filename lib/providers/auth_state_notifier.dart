import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/providers/user_notifier.dart';
import 'package:see_gas_app/utils/navigation.dart';

import '../features/authentication/entities/auth_result.dart';
import '../features/authentication/entities/auth_state.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_methods.dart';
import '../services/firebase_firestore_methods.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final FirebaseAuthMethods _auth;

  AuthStateNotifier(this._auth, this.ref) : super(const AuthState.loggedOut()) {
    if (_auth.isLoggedIn) {
      state = AuthState.success(_auth.currentUser?.uid);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String phoneContact,
    Uint8List? file,
  }) async {
    state = state.copiedWithIsLoading(true);
    final result = await _auth.signUp(
        email: email,
        username: username,
        password: password,
        contact: phoneContact);
    if (result == AuthResult.success && _auth.currentUser?.uid != null) {
      if (!_auth.isEmailVerified) {
        state = AuthState.success(_auth.currentUser?.uid);
        Navigation.skipTo(Navigation.verifyEmail);
      } else {
        state = AuthState.success(_auth.currentUser?.uid);
        Navigation.skipTo(Navigation.home);
      }
    } else {
      state =
          AuthState.failure(null, errorMessage: ref.read(errorMessageProvider));
      state = const AuthState.loggedOut();
    }
  }

  Future<void> signInWithGoogle(
      {Future<List<String?>?>? Function()? onNew}) async {
    state = state.copiedWithIsLoading(true);
    final result = await _auth.signInWithGoogle();

    if (result == AuthResult.success) {
      var userDoc = await FirestoreMethods().getUser(email: _auth.email ?? "");
      if (userDoc.docs.isNotEmpty) {
        final existingUserId = userDoc.docs.first.id;
        List<String> providerData =
            (userDoc.docs.first['providerData'] as List<dynamic>?)
                    ?.map(
                      (e) => e.toString(),
                    )
                    .toList() ??
                [];

        if (!providerData.contains('google.com')) {
          providerData.add('google.com');
          await FirestoreMethods()
              .updateUserProviderData(existingUserId, providerData);
        }

        final user = UserModel.fromMap(userDoc.docs.first.data());
        await ref.read(userProvider.notifier).cacheUser(user);
        state = AuthState.success(existingUserId);
        Navigation.skipTo(Navigation.home);
      } else {
        state = state.copiedWithIsLoading(false);
        final result = await onNew?.call();
        state = state.copiedWithIsLoading(true);

        final userModel = UserModel(
          username: result?.first ?? _auth.currentUser?.displayName ?? "",
          userId: _auth.currentUser?.uid,
          email: _auth.currentUser?.email ?? "",
          photoLink: _auth.currentUser?.photoURL,
          phoneContact: result?.last ?? "",
        );
        final providerData =
            await FirestoreMethods().getProviderData(email: userModel.email);
        if (!providerData.contains('google.com')) {
          providerData.add('google.com');
        }

        await FirestoreMethods().storeUserInfo(
          user: userModel,
          provider: providerData,
        );

        await ref.read(userProvider.notifier).cacheUser(userModel);
        state = AuthState.success(_auth.currentUser?.uid);
        Navigation.skipTo(Navigation.home);
      }
    } else if (result == AuthResult.aborted) {
      state = const AuthState.loggedOut();
    } else {
      state =
          AuthState.failure(null, errorMessage: ref.read(errorMessageProvider));
      state = const AuthState.loggedOut();
    }
  }

  Future<void> reloadUser() async {
    try {
      await _auth.reloadUser();
      if (_auth.isEmailVerified) {
        state = AuthState.success(
            _auth.currentUser?.uid); // Update state if verified
      }
    } catch (e) {
      state = AuthState.failure(_auth.currentUser?.uid,
          errorMessage: ref.read(errorMessageProvider));
    }
  }

  Future<void> sendVerificationMail({Function? onSent}) async {
    state = state.copiedWithIsLoading(true);
    final result = await _auth.sendVerificationMail();
    if (result == AuthResult.success) {
      state = state.copiedWithIsLoading(false);
      onSent?.call();
    } else {
      state = AuthState.failure(_auth.currentUser?.uid,
          errorMessage: ref.read(errorMessageProvider));
      state = AuthState.success(_auth.currentUser?.uid);
    }
  }

  Future<void> sendResetPasswordMail(
      {required String email, Function? onSent}) async {
    state = state.copiedWithIsLoading(true);
    final result = await _auth.resetPassword(email: email);
    if (result == AuthResult.success) {
      state = state.copiedWithIsLoading(false);
      onSent?.call();
    } else {
      state =
          AuthState.failure(null, errorMessage: ref.read(errorMessageProvider));
      state = AuthState.success(null);
    }
  }

  Future<void> signInWithCredentials({
    required String email,
    required String password,
  }) async {
    state = state.copiedWithIsLoading(true);
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (result == AuthResult.success && _auth.currentUser?.uid != null) {

      final user = await FirestoreMethods().getUser(email: email);
      final userModel = UserModel.fromMap(user.docs.first.data());
      await ref.read(userProvider.notifier).cacheUser(userModel);

      if (!_auth.isEmailVerified) {
        state = AuthState.success(_auth.currentUser?.uid);
        Navigation.skipTo(Navigation.verifyEmail);
      } else {
        state = AuthState.success(_auth.currentUser?.uid);
        Navigation.skipTo(Navigation.home);
      }
    } else {
      state =
          AuthState.failure(null, errorMessage: ref.read(errorMessageProvider));
      state = const AuthState.loggedOut();
    }
  }

  Future<void> linkEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copiedWithIsLoading(true);
    final result =
        await _auth.linkWithEmailPassword(email: email, password: password);
    if (result == AuthResult.success) {
      state = AuthState.success(_auth.currentUser?.uid);
    } else if (result == AuthResult.incorrect) {
      state = AuthState.failure(_auth.currentUser?.uid,
          errorMessage: ref.read(errorMessageProvider));
    } else {
      state = const AuthState.loggedOut();
    }
  }

  Future<void> signOut() async {
    state = state.copiedWithIsLoading(true);
    final result = await _auth.signOut();
    if (result == AuthResult.success) {
    await ref.read(userProvider.notifier).clearUser();
      state = const AuthState.loggedOut();
      Navigation.skipTo(Navigation.authPage);
    } else {
      state = AuthState.failure(_auth.currentUser?.uid,
          errorMessage: ref.read(errorMessageProvider));
      state = AuthState.success(_auth.currentUser?.uid);
    }
  }

  Future<void> deleteUser() async {
    state = state.copiedWithIsLoading(true);
    final result = await _auth.deleteUser(userId: _auth.currentUser?.uid ?? "");
    if (result == AuthResult.success) {
      state = const AuthState.loggedOut();
    } else {
      state = AuthState.failure(_auth.currentUser?.uid,
          errorMessage: ref.read(errorMessageProvider));
      state = AuthState.success(_auth.currentUser?.uid);
    }
  }

  Future<void> removeDevice(String deviceId) async {
    state = state.copiedWithIsLoading(true);
    final result = await FirestoreMethods().deleteDevice(ref, deviceId);
    if (result == AuthResult.success) {
      state = state.copiedWithIsLoading(false);
      Navigation.close();
    } else {
      state = AuthState.failure(_auth.currentUser?.uid,
          errorMessage: ref.read(errorMessageProvider));
      state = AuthState.success(_auth.currentUser?.uid);
    }
  }
}

class ErrorMessageNotifier extends StateNotifier<String?> {
  ErrorMessageNotifier() : super(null);

  void setError([String? message]) {
    state = message ?? "Oops. Something went wrong";
  }

  void clearError() {
    state = null;
  }
}

final errorMessageProvider =
    StateNotifierProvider<ErrorMessageNotifier, String?>((ref) {
  return ErrorMessageNotifier();
});

final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) {
    final firebaseAuthMethods = ref.watch(firebaseAuthMethodsProvider);
    return AuthStateNotifier(firebaseAuthMethods, ref);
  },
);

final firebaseAuthMethodsProvider = Provider<FirebaseAuthMethods>((ref) {
  final FirebaseAuth auth = FirebaseAuth.instance;
  return FirebaseAuthMethods(ref, auth);
});

final emailVerifiedProvider = Provider<bool>(
  (ref) => FirebaseAuth.instance.currentUser?.emailVerified ?? false,
);
