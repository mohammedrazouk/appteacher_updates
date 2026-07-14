import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/storage_helper.dart';
import '../models/ladder_result.dart';

class HistoryViewScreen extends StatefulWidget {
  const HistoryViewScreen({super.key});

  @override
  State<HistoryViewScreen> createState() => _HistoryViewScreenState();
}

class _HistoryViewScreenState extends State<HistoryViewScreen> {
  List<LadderResult> _results = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await LadderStorage.loadResults();
    setState(() => _results = results.reversed.toList());
  }

  Future<void> _delete(String id) async {
    await LadderStorage.deleteResult(id);
    _load();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف جميع النتائج'),
        content: const Text('هل أنت متأكد من حذف جميع النتائج؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true) {
      await LadderStorage.clearAll();
      _load();
    }
  }

  Future<void> _shareSingle(LadderResult result) async {
    final buffer = StringBuffer();
    buffer.writeln('📖 نتيجة سلالم الاختبار');
    buffer.writeln('━━━━━━━━━━━━━━');
    buffer.writeln('الطالب: ${result.studentName}');
    buffer.writeln('الاختبار: ${result.stage}');
    buffer.writeln('التقدير: ${result.grade}');
    if (result.errors.isNotEmpty) {
      buffer.writeln('━━━━━━━━━━━━━━');
      for (final e in result.errors) {
        buffer.writeln('  - ${e.name}: ${e.count} مرات');
      }
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ النتيجة')),
      );
    }
  }

  Future<void> _shareAll() async {
    final buffer = StringBuffer();
    buffer.writeln('📊 سجل نتائج سلالم الاختبار');
    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    for (int i = 0; i < _results.length; i++) {
      final r = _results[i];
      buffer.writeln(
        '${i + 1}. ${r.studentName} | ${r.stage} | ${r.grade} | '
        '${r.timestamp.year}/${r.timestamp.month}/${r.timestamp.day}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ جميع النتائج')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const gradeColors = {
      'تفوق': Color(0xFF059669),
      'ممتاز': Color(0xFF2563EB),
      'جيد جداً': Color(0xFFD97706),
      'جيد': Color(0xFFEA580C),
      'إعادة': Color(0xFFDC2626),
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('سجل النتائج',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_right, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _results.isNotEmpty
            ? [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Text(
                      '${_results.length}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: _results.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('لا توجد نتائج محفوظة',
                      style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('قم بتقييم طالب أولاً',
                      style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12)),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareAll,
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('مشاركة الجميع'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1CA390),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('حذف الكل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final gradeColor = gradeColors[result.grade] ?? Colors.grey;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.studentName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      result.stage,
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: gradeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    result.grade,
                                    style: TextStyle(
                                      color: gradeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (result.errors.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: result.errors.map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 1),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(e.name,
                                              style: const TextStyle(
                                                  color: Color(0xFF475569), fontSize: 12)),
                                          Text('${e.count} مرات',
                                              style: const TextStyle(
                                                  color: Color(0xFF94A3B8), fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ).toList(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${result.timestamp.year}/${result.timestamp.month}/${result.timestamp.day}',
                                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _shareSingle(result),
                                      icon: const Icon(Icons.share, size: 18),
                                      color: const Color(0xFF1CA390),
                                      tooltip: 'مشاركة',
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    IconButton(
                                      onPressed: () => _delete(result.id),
                                      icon: const Icon(Icons.delete, size: 18),
                                      color: Colors.redAccent,
                                      tooltip: 'حذف',
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
