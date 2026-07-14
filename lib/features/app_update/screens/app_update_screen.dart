import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../services/app_update_service.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({super.key});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  String _currentVersion = '';
  bool _checking = false;
  bool _downloading = false;
  double _downloadProgress = 0;
  String? _error;
  Map<String, dynamic>? _remoteInfo;
  bool _updateAvailable = false;
  String? _apkPath;

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    final v = await AppUpdateService.getCurrentVersionName();
    setState(() => _currentVersion = v);
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _checking = true;
      _error = null;
      _remoteInfo = null;
      _updateAvailable = false;
    });
    try {
      final info = await AppUpdateService.fetchVersionInfo();
      final available = await AppUpdateService.isUpdateAvailable(info);
      setState(() {
        _remoteInfo = info;
        _updateAvailable = available;
        _checking = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _checking = false;
      });
    }
  }

  Future<void> _downloadAndInstall() async {
    if (_remoteInfo == null) return;
    final versionName = _remoteInfo!['versionName'] as String;

    setState(() {
      _downloading = true;
      _downloadProgress = 0;
      _error = null;
    });

    try {
      await AppUpdateService.backupDatabase();

      final path = await AppUpdateService.downloadApk(
        version: versionName,
        onProgress: (p) {
          if (mounted) setState(() => _downloadProgress = p);
        },
      );

      setState(() {
        _apkPath = path;
        _downloading = false;
      });

      await AppUpdateService.installApk(path);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تحديث البرنامج'),
        backgroundColor: AppColors.brandBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            if (_error != null) _buildErrorCard(),
            if (_checking) const LinearProgressIndicator(),
            if (_downloading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _downloadProgress),
              const SizedBox(height: 8),
              Text(
                'جارٍ التحميل ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            if (_remoteInfo != null && _updateAvailable) _buildUpdateCard(),
            if (_remoteInfo != null && !_updateAvailable)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.brandTeal, size: 28),
                        SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'البرنامج محدث لأحدث إصدار',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _checking || _downloading ? null : _checkForUpdate,
                icon: Icon(_checking ? Icons.hourglass_top : Icons.update),
                label: Text(_checking ? 'جارٍ التحقق...' : 'التحقق من وجود تحديث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline, color: AppColors.brandBlue, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'الإصدار الحالي',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _currentVersion.isEmpty ? '...' : _currentVersion,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.brandBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: AppColors.statusRed.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.statusRed),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.statusRed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateCard() {
    final versionName = _remoteInfo!['versionName'] as String;
    final changelog = _remoteInfo!['changelog'] as String? ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.system_update, color: AppColors.brandBlue, size: 28),
                SizedBox(width: 12),
                Text(
                  'تحديث متوفر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'الإصدار: $versionName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.brandTeal,
              ),
            ),
            if (changelog.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  changelog,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _downloading ? null : _downloadAndInstall,
                icon: _downloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : _apkPath != null
                        ? const Icon(Icons.download_done)
                        : const Icon(Icons.download),
                label: Text(_downloading
                    ? 'جاري التحميل...'
                    : _apkPath != null
                        ? 'فتح المثبت'
                        : 'تحميل وتثبيت'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
