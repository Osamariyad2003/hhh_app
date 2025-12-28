import '../models/user_model.dart';

/// Abstract base class for Auth states
abstract class AuthState {
  const AuthState();
}

/// Initial state - auth status is unknown
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - authentication in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state - user is signed in
class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String token;

  const AuthAuthenticated({
    required this.user,
    required this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated &&
          runtimeType == other.runtimeType &&
          user.id == other.user.id &&
          token == other.token;

  @override
  int get hashCode => user.id.hashCode ^ token.hashCode;
}

/// Unauthenticated state - user is signed out
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state - authentication error occurred
class AuthError extends AuthState {
  final String message;
  final AuthState? previousState;

  const AuthError(this.message, {this.previousState});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

