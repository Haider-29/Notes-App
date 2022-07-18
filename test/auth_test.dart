import 'package:learningdart/constants/routes.dart';
import 'package:learningdart/services/auth/auth_exceptions.dart';
import 'package:learningdart/services/auth/auth_provider.dart';
import 'package:learningdart/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialzed', () {
      expect(provider.isInitialzed, false);
    });
    test('No logout without initialzde', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitialzedException>()),
      );
    });
    test('Initialize test', () async {
      await provider.initialze();
      expect(provider.isInitialzed, true);
    });
    test('User should be null', () {
      expect(provider.currentUser, null);
    });
    test(
      'Time of initialization',
      () async {
        await provider.initialze();
        expect(provider.isInitialzed, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Creating a user', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'Whatever dude',
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      final badPassWordUser = provider.createUser(
        email: 'someone@bar.com',
        password: 'foobar',
      );

      expect(
        badPassWordUser,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      final user = await provider.createUser(email: 'foo', password: 'bar');

      expect(
        provider.currentUser,
        user,
      );

      expect(
        user.isEmailVerified,
        false,
      );
    });

    test('Login should be able to verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to logout and login', () async {
      await provider.logOut();
      await provider.login(email: 'hi', password: 'bye');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitialzedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialzed = false;
  bool get isInitialzed => _isInitialzed;
  AuthUser? _user;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialzed) {
      throw NotInitialzedException();
    }
    await Future.delayed(const Duration(seconds: 1));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialze() async {
    _isInitialzed = true;
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<void> logOut() async {
    if (!isInitialzed) throw NotInitialzedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    if (!isInitialzed) throw NotInitialzedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialzed) throw NotInitialzedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
