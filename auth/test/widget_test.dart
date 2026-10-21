import 'package:flutter_test/flutter_test.dart';
import 'package:auth/main.dart';
import 'package:auth/features/auth/data/models/login_response_model.dart';
import 'package:auth/features/auth/data/models/user_model.dart';
import 'package:auth/features/auth/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    return const LoginResponseModel(
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String avatar,
  }) async {
    return UserModel(
      id: 1,
      email: email,
      name: name,
      role: 'customer',
      avatar: avatar,
    );
  }

  @override
  Future<UserModel> getProfile({required String token}) async {
    return const UserModel(
      id: 1,
      email: 'john@mail.com',
      name: 'John Doe',
      role: 'customer',
      avatar: 'https://picsum.photos/800',
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders login screen with email and password fields', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();

    await tester.pumpWidget(MyApp(authRepository: mockRepo));
    await tester.pumpAndSettle();

    // Verify Welcome Back and Sign In are rendered
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
