import 'package:get_storage/get_storage.dart';

class AuthRepository {
  final GetStorage _storage = GetStorage();

  Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _storage.write('isLoggedIn', isLoggedIn);
  }

  bool getLoginStatus() {
    return _storage.read('isLoggedIn') ?? false;
  }
}