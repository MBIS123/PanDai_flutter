// user_data.dart

class UserData {
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;

  UserData._internal();

  int _userId = 0;

  int get userId => _userId;

  void setUserId(int userId) {
    _userId = userId;
  }
}
