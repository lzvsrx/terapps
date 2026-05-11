import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackupConfig {
  BackupConfig({
    required this.enabled,
    required this.owner,
    required this.repo,
    required this.branch,
    required this.path,
    required this.intervalMinutes,
  });

  final bool enabled;
  final String owner;
  final String repo;
  final String branch;
  final String path;
  final int intervalMinutes;
}

class GitHubBackupService {
  GitHubBackupService._();

  static const _secure = FlutterSecureStorage();
  static const _tokenKey = 'github_pat';
  static Timer? _timer;

  static Future<void> saveConfig(BackupConfig config, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('backup_enabled', config.enabled);
    await prefs.setString('backup_owner', config.owner.trim());
    await prefs.setString('backup_repo', config.repo.trim());
    await prefs.setString('backup_branch', config.branch.trim());
    await prefs.setString('backup_path', config.path.trim());
    await prefs.setInt('backup_interval', config.intervalMinutes);
    if (token.trim().isNotEmpty) {
      await _secure.write(key: _tokenKey, value: token.trim());
    }
  }

  static Future<BackupConfig> readConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return BackupConfig(
      enabled: prefs.getBool('backup_enabled') ?? false,
      owner: prefs.getString('backup_owner') ?? '',
      repo: prefs.getString('backup_repo') ?? '',
      branch: prefs.getString('backup_branch') ?? 'main',
      path: prefs.getString('backup_path') ?? 'backups/tera-db-snapshot.json',
      intervalMinutes: prefs.getInt('backup_interval') ?? 15,
    );
  }

  static Future<void> stopPeriodic() async {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> startPeriodic({required Future<String> Function() buildSnapshotJson}) async {
    await stopPeriodic();
    final config = await readConfig();
    if (!config.enabled) return;

    _timer = Timer.periodic(Duration(minutes: config.intervalMinutes.clamp(5, 240)), (_) async {
      try {
        await pushBackup(buildSnapshotJson: buildSnapshotJson);
      } catch (_) {}
    });
  }

  static Future<void> pushBackup({required Future<String> Function() buildSnapshotJson}) async {
    final config = await readConfig();
    final token = await _secure.read(key: _tokenKey) ?? '';

    if (!config.enabled || token.isEmpty || config.owner.isEmpty || config.repo.isEmpty || config.path.isEmpty) {
      throw Exception('Configuração de backup incompleta.');
    }

    final content = await buildSnapshotJson();
    final uri = Uri.parse('https://api.github.com/repos/${config.owner}/${config.repo}/contents/${config.path}');

    String? sha;
    final getResp = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    });
    if (getResp.statusCode == 200) {
      final body = jsonDecode(getResp.body) as Map<String, dynamic>;
      sha = body['sha'] as String?;
    }

    final body = {
      'message': 'chore: backup db snapshot ${DateTime.now().toUtc().toIso8601String()}',
      'content': base64Encode(utf8.encode(content)),
      'branch': config.branch,
      if (sha != null) 'sha': sha,
    };

    final putResp = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
      body: jsonEncode(body),
    );

    if (putResp.statusCode < 200 || putResp.statusCode >= 300) {
      throw Exception('Falha no backup GitHub: ${putResp.statusCode} ${putResp.body}');
    }
  }
}
