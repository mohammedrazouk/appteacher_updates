import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/errors_data.dart';
import '../data/grade_calculator.dart';
import '../data/storage_helper.dart';
import '../models/ladder_result.dart';
import 'history_view_screen.dart';

class ResultScreen extends StatefulWidget {
  final String studentName;
  final int stageIndex;
  final List<ErrorButton> errorButtons;
  final Map<String, int> counts;
  final double tajweedTheoryDeduction;

  const ResultScreen({
    super.key,
    required this.studentName,
    required this.stageIndex,
    required this.errorButtons,
    required this.counts,
    this.tajweedTheoryDeduction = 0,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _captureKey = GlobalKey();
  bool _sharing = false;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final quranDeductions = widget.errorButtons.fold<double>(
      0,
      (sum, e) => sum + (widget.counts[e.id] ?? 0) * e.deduction,
    );
    final totalDeductions = quranDeductions + widget.tajweedTheoryDeduction;
    final activeErrors = widget.errorButtons
        .where((e) => (widget.counts[e.id] ?? 0) > 0)
        .map((e) => ErrorEntry(name: e.name, count: widget.counts[e.id]!))
        .toList();
    if (widget.tajweedTheoryDeduction > 0) {
      activeErrors.insert(0, ErrorEntry(name: 'التجويد النظري', count: 1));
    }
    final grade = computeGradeFromDeductions(totalDeductions);

    await LadderStorage.saveResult(
      LadderResult(
        id: generateId(),
        studentName: widget.studentName,
        stage: stages[widget.stageIndex],
        errors: activeErrors,
        totalDeductions: totalDeductions,
        grade: grade,
        timestamp: DateTime.now(),
      ),
    );

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ النتيجة بنجاح')),
      );
    }
  }

  Future<void> _shareAsText() async {
    final quranDeductions = widget.errorButtons.fold<double>(
      0,
      (sum, e) => sum + (widget.counts[e.id] ?? 0) * e.deduction,
    );
    final totalDeductions = quranDeductions + widget.tajweedTheoryDeduction;
    final grade = computeGradeFromDeductions(totalDeductions);
    final activeErrors = widget.errorButtons
        .where((e) => (widget.counts[e.id] ?? 0) > 0)
        .map((e) => ErrorEntry(name: e.name, count: widget.counts[e.id]!))
        .toList();
    if (widget.tajweedTheoryDeduction > 0) {
      activeErrors.insert(0, ErrorEntry(name: 'التجويد النظري', count: 1));
    }

    final buffer = StringBuffer();
    buffer.writeln('📖 نتيجة سلالم الاختبار');
    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    buffer.writeln('الطالب: ${widget.studentName}');
    buffer.writeln('الاختبار: ${stages[widget.stageIndex]}');
    buffer.writeln('التقدير: $grade');
    if (activeErrors.isNotEmpty) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━');
      for (final e in activeErrors) {
        buffer.writeln('${e.name}: ${e.count} مرات');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ النتيجة')),
      );
    }
  }

  Future<void> _shareAsImage() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw 'لم يتم العثور على البطاقة';
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw 'فشل تحويل الصورة';
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/result_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'نتيجة اختبار ${widget.studentName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذرت المشاركة كصورة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranDeductions = widget.errorButtons.fold<double>(
      0,
      (sum, e) => sum + (widget.counts[e.id] ?? 0) * e.deduction,
    );
    final totalDeductions = quranDeductions + widget.tajweedTheoryDeduction;
    final grade = computeGradeFromDeductions(totalDeductions);
    final activeErrors = widget.errorButtons
        .where((e) => (widget.counts[e.id] ?? 0) > 0)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('النتيجة',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: RepaintBoundary(
          key: _captureKey,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 28),
                const Text(
                  'نتيجة تقييم التلاوة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'تطبيق التقييم القرآني الرسمي',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFA7F3D0).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      _row('الطالب', widget.studentName),
                      const Divider(height: 24, color: Color(0xFFA7F3D0)),
                      _row('الاختبار', stages[widget.stageIndex]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFF1F5F9)),
                      bottom: BorderSide(color: Color(0xFFF1F5F9)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 20, color: Colors.amber.shade500),
                          const SizedBox(width: 8),
                          Text(
                            'ملخص الملاحظات',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (activeErrors.isEmpty &&
                          widget.tajweedTheoryDeduction <= 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'لا توجد ملاحظات، تلاوة متقنة!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else ...[
                        if (widget.tajweedTheoryDeduction > 0)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.menu_book,
                                          size: 16, color: Color(0xFFB45309)),
                                      const SizedBox(width: 6),
                                      Text('التجويد النظري',
                                          style: TextStyle(
                                              color: const Color(0xFFB45309),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.tajweedTheoryDeduction ==
                                            widget.tajweedTheoryDeduction
                                                .truncateToDouble()
                                        ? '-${widget.tajweedTheoryDeduction.toInt()}'
                                        : '-${widget.tajweedTheoryDeduction.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: Color(0xFFB91C1C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ...activeErrors.map(
                          (e) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(e.name,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13)),
                                ),
                                Text(
                                  '×${widget.counts[e.id] ?? 0}',
                                  style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '-${(e.deduction * (widget.counts[e.id] ?? 0)).toStringAsFixed(e.deduction.truncateToDouble() == e.deduction ? 0 : 1)}',
                                    style: const TextStyle(
                                      color: Color(0xFFB91C1C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calculate_outlined,
                                      size: 18, color: Color(0xFFB91C1C)),
                                  SizedBox(width: 6),
                                  Text(
                                    'مجموع العلامات المخصومة',
                                    style: TextStyle(
                                      color: Color(0xFFB91C1C),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                totalDeductions ==
                                        totalDeductions.truncateToDouble()
                                    ? '-${totalDeductions.toInt()}'
                                    : '-${totalDeductions.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'العلامة النهائية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Builder(builder: (context) {
                  final score = computeFinalScore(totalDeductions);
                  final scoreColor = score < 79
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF065F46);
                  return Column(
                    children: [
                      Text(
                        '${score.toStringAsFixed(1)} / 100',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 36,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: scoreColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'التقدير: $grade',
                          style: TextStyle(
                            color: scoreColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  size: 18, color: Color(0xFF065F46)),
                              SizedBox(width: 6),
                              Text('تم الحفظ',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF065F46))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _sharing ? null : _shareAsImage,
                          icon: _sharing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.image, size: 18),
                          label: Text(_sharing ? 'جاري...' : 'مشاركة صورة',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1CA390),
                            side: const BorderSide(color: Color(0xFF1CA390)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _shareAsText,
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('نسخ كنص',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1CA390),
                            side: const BorderSide(color: Color(0xFF1CA390)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HistoryViewScreen()),
                            (route) => false,
                          ),
                          icon: const Icon(Icons.history, size: 18),
                          label: const Text('السجل',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Color(0xFF065F46), fontSize: 14)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 16)),
      ],
    );
  }
}
