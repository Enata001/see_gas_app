import 'package:flutter/foundation.dart' show immutable;
import '../../../utils/typedefs.dart';
import 'auth_result.dart';

@immutable
class AuthState {
  final AuthResult? result;
  final bool isLoading;
  final UserId? userId;
  final String? errorMessage;

  const AuthState(
      {required this.result,
      required this.isLoading,
      required this.userId,
      this.errorMessage});

  const AuthState.loggedOut()
      : result = null,
        isLoading = false,
        userId = null,
        errorMessage = null;

  const AuthState.success(this.userId)
      : result = AuthResult.success,
        errorMessage = null,
        isLoading = false;

  AuthState copiedWithIsLoading(bool isLoading) => AuthState(
        result: result,
        isLoading: isLoading,
        userId: userId,
      );

  const AuthState.failure(this.userId, {this.errorMessage})
      : result = AuthResult.failure,
        isLoading = false;


  @override
  bool operator ==(covariant AuthState other) =>
      identical(this, other) ||
      (result == other.result &&
          isLoading == other.isLoading &&
          userId == other.userId);

  @override
  int get hashCode => Object.hash(
        result,
        isLoading,
        userId,
      );
}
