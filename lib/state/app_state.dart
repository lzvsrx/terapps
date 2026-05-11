import 'package:flutter/foundation.dart';

import '../data/app_database.dart';
import '../data/github_backup_service.dart';
import '../data/models.dart';

class AppState extends ChangeNotifier {
  final AppDatabase _database = AppDatabase.instance;

  User? user;
  List<ProfessionPreset> professions = [];
  List<WorkRecord> records = [];
  bool highContrast = false;
  double textScale = 1.0;
  bool onlyFavorites = false;
  String searchQuery = '';

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
    await GitHubBackupService.startPeriodic(buildSnapshotJson: _snapshotBuilder);
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

  Future<void> updateRecord({
    required int id,
    required String profession,
    required String type,
    required String title,
    required String content,
  }) async {
    await _database.updateRecord(id: id, profession: profession, type: type, title: title, content: content);
    await refreshRecords();
    notifyListeners();
  }

  Future<void> deleteRecord(int id) async {
    await _database.deleteRecord(id);
    await refreshRecords();
    notifyListeners();
  }

  Future<void> toggleFavorite(WorkRecord record) async {
    await _database.toggleFavorite(record.id, !record.isFavorite);
    await refreshRecords();
    notifyListeners();
  }

  Future<void> refreshRecords() async {
    if (user == null) {
      records = [];
      return;
    }
    records = await _database.getRecords(user!.id, query: searchQuery, onlyFavorites: onlyFavorites);
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    refreshRecords().then((_) => notifyListeners());
  }

  void setOnlyFavorites(bool value) {
    onlyFavorites = value;
    refreshRecords().then((_) => notifyListeners());
  }

  void toggleContrast(bool value) {
    highContrast = value;
    notifyListeners();
  }

  void setScale(double value) {
    textScale = value;
    notifyListeners();
  }

  Future<void> saveBackupConfig(BackupConfig config, String token) async {
    await GitHubBackupService.saveConfig(config, token);
    if (user != null) {
      await GitHubBackupService.startPeriodic(buildSnapshotJson: _snapshotBuilder);
    }
  }

  Future<void> backupNow() async {
    await GitHubBackupService.pushBackup(buildSnapshotJson: _snapshotBuilder);
  }

  Future<String> _snapshotBuilder() async {
    if (user == null) return '{}';
    return _database.exportUserSnapshotJson(user!.id);
  }

  Future<void> logout() async {
    user = null;
    records = [];
    await GitHubBackupService.stopPeriodic();
    notifyListeners();
  }
}
