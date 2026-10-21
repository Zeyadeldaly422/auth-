import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/cache_helper.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

  static AuthCubit get(BuildContext context) => BlocProvider.of<AuthCubit>(context);

  UserModel? currentUser;
  String? token;

  bool isPasswordHidden = true;
  bool isRegisterPasswordHidden = true;

  void togglePasswordVisibility() {
    isPasswordHidden = !isPasswordHidden;
    emit(AuthInitial());
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordHidden = !isRegisterPasswordHidden;
    emit(AuthInitial());
  }

  Future<void> checkAuthStatus() async {
    final cachedToken = CacheHelper.getString(key: CacheHelper.tokenKey);
    if (cachedToken != null && cachedToken.isNotEmpty) {
      token = cachedToken;
      await getProfile(userToken: cachedToken);
    } else {
      emit(UnauthenticatedState());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(LoginLoadingState());
    try {
      final response = await authRepository.login(
        email: email,
        password: password,
      );

      token = response.accessToken;
      await CacheHelper.saveData(
        key: CacheHelper.tokenKey,
        value: response.accessToken,
      );
      await CacheHelper.saveData(
        key: CacheHelper.refreshTokenKey,
        value: response.refreshToken,
      );

      emit(LoginSuccessState(loginResponse: response));

      // Fetch user profile immediately after successful login
      await getProfile(userToken: response.accessToken);
    } on ServerException catch (e) {
      emit(LoginErrorState(message: e.message));
    } catch (e) {
      emit(LoginErrorState(message: e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String avatar,
  }) async {
    emit(RegisterLoadingState());
    try {
      final user = await authRepository.register(
        name: name,
        email: email,
        password: password,
        avatar: avatar,
      );
      emit(RegisterSuccessState(user: user));
    } on ServerException catch (e) {
      emit(RegisterErrorState(message: e.message));
    } catch (e) {
      emit(RegisterErrorState(message: e.toString()));
    }
  }

  Future<void> getProfile({String? userToken}) async {
    final currentToken = userToken ?? token ?? CacheHelper.getString(key: CacheHelper.tokenKey);
    if (currentToken == null || currentToken.isEmpty) {
      emit(UnauthenticatedState());
      return;
    }

    emit(ProfileLoadingState());
    try {
      final user = await authRepository.getProfile(token: currentToken);
      currentUser = user;
      emit(ProfileSuccessState(user: user));
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        await logout();
      } else {
        emit(ProfileErrorState(message: e.message));
      }
    } catch (e) {
      emit(ProfileErrorState(message: e.toString()));
    }
  }

  Future<void> logout() async {
    await CacheHelper.removeData(key: CacheHelper.tokenKey);
    await CacheHelper.removeData(key: CacheHelper.refreshTokenKey);
    currentUser = null;
    token = null;
    emit(UnauthenticatedState());
  }
}

