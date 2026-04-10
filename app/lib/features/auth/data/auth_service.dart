class AuthService {
  const AuthService();

  Future<bool> login({
    required String mobile,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return mobile.startsWith('+63') && password.isNotEmpty;
  }

  Future<bool> register({
    required String fullName,
    required String farmName,
    required String mobile,
    required String password,
    String? referralCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return fullName.isNotEmpty &&
        farmName.isNotEmpty &&
        mobile.startsWith('+63') &&
        password.isNotEmpty;
  }

  Future<bool> verifyOtp({required String mobile, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return code.length == 6;
  }

  Future<void> resendOtp({required String mobile}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Future<void> activateTrial({required String mobile}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
