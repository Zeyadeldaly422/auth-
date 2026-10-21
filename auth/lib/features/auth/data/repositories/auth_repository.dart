import '../../../../core/constants/end_points.dart';
import '../../../../core/network/api_consumer.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String avatar,
  });

  Future<UserModel> getProfile({
    required String token,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiConsumer apiConsumer;

  AuthRepositoryImpl({required this.apiConsumer});

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiConsumer.post(
      EndPoints.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );
    return LoginResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String avatar,
  }) async {
    final response = await apiConsumer.post(
      EndPoints.users,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'avatar': avatar.trim(),
      },
    );
    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getProfile({
    required String token,
  }) async {
    final response = await apiConsumer.get(
      EndPoints.profile,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return UserModel.fromJson(response as Map<String, dynamic>);
  }
}

