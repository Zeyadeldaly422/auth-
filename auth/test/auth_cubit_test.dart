import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth/core/utils/cache_helper.dart';
import 'package:auth/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:auth/features/auth/presentation/cubit/auth_state.dart';
import 'package:auth/features/auth/data/models/login_response_model.dart';
import 'package:auth/features/auth/data/models/user_model.dart';
import 'package:auth/features/auth/data/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldFail = false;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) throw Exception('Invalid credentials');
    return const LoginResponseModel(
      accessToken: 'test_token',
      refreshToken: 'test_refresh_token',
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String avatar,
  }) async {
    if (shouldFail) throw Exception('Registration failed');
    return UserModel(
      id: 10,
      email: email,
      name: name,
      role: 'customer',
      avatar: avatar,
    );
  }

  @override
  Future<UserModel> getProfile({required String token}) async {
    if (shouldFail) throw Exception('Failed to load profile');
    return const UserModel(
      id: 10,
      email: 'john@mail.com',
      name: 'John Doe',
      role: 'customer',
      avatar: 'https://picsum.photos/800',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockRepository;
  late AuthCubit authCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
    mockRepository = MockAuthRepository();
    authCubit = AuthCubit(authRepository: mockRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  test('Initial state is AuthInitial', () {
    expect(authCubit.state, isA<AuthInitial>());
  });

  test('Successful login emits LoginLoadingState, LoginSuccessState, and ProfileSuccessState', () async {
    final expectedStates = [
      isA<LoginLoadingState>(),
      isA<LoginSuccessState>(),
      isA<ProfileLoadingState>(),
      isA<ProfileSuccessState>(),
    ];

    expectLater(authCubit.stream, emitsInOrder(expectedStates));

    await authCubit.login(email: 'john@mail.com', password: 'changeme');
    expect(authCubit.token, equals('test_token'));
    expect(authCubit.currentUser?.name, equals('John Doe'));
  });

  test('Logout clears cached token and user and emits UnauthenticatedState', () async {
    await CacheHelper.saveData(key: CacheHelper.tokenKey, value: 'test_token');
    authCubit.token = 'test_token';

    expectLater(authCubit.stream, emits(isA<UnauthenticatedState>()));

    await authCubit.logout();
    expect(authCubit.token, isNull);
    expect(authCubit.currentUser, isNull);
    expect(CacheHelper.getString(key: CacheHelper.tokenKey), isNull);
  });
}

