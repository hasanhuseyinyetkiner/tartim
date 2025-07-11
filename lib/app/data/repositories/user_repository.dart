import 'package:tartim/app/data/database/database_helper.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<bool> login(String username, String password) async {
    final results = await _databaseHelper.queryWhere(
      'users',
      'username = ? AND password = ?',
      [username, password],
    );
    return results.isNotEmpty;
  }

  Future<void> logout() async {
    // In a real app, you might want to clear some session data here
    print('User logged out');
  }

  // Toplam hayvan sayısını getirme metodu
  Future<int> getTotalAnimalCount() async {
    try {
      final result = await _databaseHelper.queryAllRows('animals');
      return result.length;
    } catch (e) {
      print('Error getting total animal count: $e');
      return 0;
    }
  }
}
