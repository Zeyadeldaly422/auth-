import 'package:equatable/equatable.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

// Login States
class LoginLoadingState extends AuthState {}

class LoginSuccessState extends AuthState {
  final LoginResponseModel loginResponse;

  const LoginSuccessState({required this.loginResponse});

  @override
  List<Object?> get props => [loginResponse];
}

class LoginErrorState extends AuthState {
  final String message;

  const LoginErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Register States
class RegisterLoadingState extends AuthState {}

class RegisterSuccessState extends AuthState {
  final UserModel user;

  const RegisterSuccessState({required this.user});

  @override
  List<Object?> get props => [user];
}

class RegisterErrorState extends AuthState {
  final String message;

  const RegisterErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Profile States
class ProfileLoadingState extends AuthState {}

class ProfileSuccessState extends AuthState {
  final UserModel user;

  const ProfileSuccessState({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileErrorState extends AuthState {
  final String message;

  const ProfileErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// Unauthenticated State
class UnauthenticatedState extends AuthState {}

