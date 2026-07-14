import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/app_update_config.dart';

class AppUpdateService {
  static String get _versionUrl =>
      'https://raw.githubusercontent.com/${AppUpdateConfig.githubOwner}/${AppUpdateConfig.githubRepo}/${AppUpdateConfig.branch}/version.json';

  static String apkDownloadUrl(String version) =>
      'https://github.com/${AppUpdateConfig.githubOwner}/${AppUpdateConfig.githubRepo}/releases/download/v$version/appteacher.apk';

  static Future<PackageInfo> _getPackageInfo() => PackageInfo.fromPlatform();

  static Future<Map<String, dynamic>> fetchVersionInfo() async {
    final res = await http.get(Uri.parse(_versionUrl)).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('فشل الاتصال: ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<int> getCurrentVersionCode() async {
    final info = await _getPackageInfo();
    return int.tryParse(info.buildNumber) ?? 1;
  }

  static Future<String> getCurrentVersionName() async {
    final info = await _getPackageInfo();
    return info.version;
  }

  static Future<bool> isUpdateAvailable(Map<String, dynamic> remote) async {
    final current = await getCurrentVersionCode();
    final remoteCode = remote['versionCode'] as int;
    return remoteCode > current;
  }

  static Future<File> backupDatabase() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbDir.path, 'appteacher.db'));
    if (!await dbFile.exists()) throw Exception('قاعدة البيانات غير موجودة');

    final backupDir = await getTemporaryDirectory();
    final backupPath = p.join(backupDir.path, 'appteacher_backup_${DateTime.now().millisecondsSinceEpoch}.db');
    final backup = await dbFile.copy(backupPath);
    return backup;
  }

  static Future<String> downloadApk({
    required String version,
    required void Function(double progress) onProgress,
  }) async {
    final url = apkDownloadUrl(version);
    final dir = await getTemporaryDirectory();
    final filePath = p.join(dir.path, 'appteacher_$version.apk');

    final res = await http.Client().send(http.Request('GET', Uri.parse(url)));
    if (res.statusCode != 200) throw Exception('فشل التحميل: ${res.statusCode}');

    final total = res.contentLength ?? 0;
    var received = 0;
    final file = File(filePath);
    final sink = file.openWrite();

    await for (final chunk in res.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) onProgress(received / total);
    }
    await sink.close();
    return filePath;
  }

  static Future<void> installApk(String filePath) async {
    final result = await OpenFilex.open(filePath, type: 'application/vnd.android.package-archive');
    if (result.type != ResultType.done) {
      throw Exception('فشل فتح المثبت: ${result.message}');
    }
  }
}
