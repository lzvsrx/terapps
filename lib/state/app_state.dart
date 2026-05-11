import 'package:flutter/foundation.dart';

import '../data/app_database.dart';
import '../data/models.dart';

class AppState extends ChangeNotifier {
  final AppDatabase _database = AppDatabase.instance;

  User? user;
  List<ProfessionPreset> professions = [];
  List<WorkRecord> records = [];
  bool highContrast = false;
  double textScale = 1.0;

  Future<void> init() async {
    professions = await _database.getProfessions();
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String profession,
    required String password,
  }) {
    return _database.registerUser(
      name: name,
      email: email,
      profession: profession,
      password: password,
    );
  }

  Future<bool> login(String email, String password) async {
    final logged = await _database.login(email: email, password: password);
    if (logged == null) return false;
    user = logged;
    await refreshRecords();
    notifyListeners();
    return true;
  }

  Future<void> addRecord({
    required String profession,
    required String type,
    required String title,
    required String content,
  }) async {
    if (user == null) return;
    await _database.addRecord(
      userId: user!.id,
      profession: profession,
      type: type,
      title: title,
      content: content,
    );
    await refreshRecords();
    notifyListeners();
  }

  Future<void> refreshRecords() async {
    if (user == null) {
      records = [];
      return;
    }
    records = await _database.getRecords(user!.id);
  }

  void toggleContrast(bool value) {
    highContrast = value;
    notifyListeners();
  }

  void setScale(double value) {
    textScale = value;
    notifyListeners();
  }

  void logout() {
    user = null;
    records = [];
    notifyListeners();
  }
}
