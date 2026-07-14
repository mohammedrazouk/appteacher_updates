import 'dart:io';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/logic/stats_calculator.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/models/student_model.dart';

class ReportService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static bool _fontsLoaded = false;

  static Future<void> _ensureFontsLoaded() async {
    if (_fontsLoaded) return;
    try {
      final regularData =
          await rootBundle.load('assets/fonts/Arial-Regular.ttf');
      _regularFont = pw.Font.ttf(regularData);
      _boldFont = pw.Font.ttf(regularData);
      _fontsLoaded = true;
    } catch (e) {
      debugPrint('Failed to load Arial font: $e');
    }
  }

  static pw.TextStyle _ts({
    double size = 10,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.TextStyle(
      font: bold ? _boldFont : _regularFont,
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color ?? PdfColors.grey900,
    );
  }

  static Future<Uint8List> generateClassReport({
    required ClassModel classData,
    required List<StudentModel> students,
    required List<ExamModel> classExams,
  }) async {
    await _ensureFontsLoaded();

    final doc = pw.Document(
      title: 'تقرير إنجاز الخطة',
      author: 'مؤسسة إتقان للتعليم والتنمية',
    );

    final total = students.length;
    final active = students.where((s) => s.isActive).length;
    final suspended = total - active;
    final rating = StatsCalculator.classRating(students, classExams);
    final avg = StatsCalculator.classAverage(students, classExams);
    final perfect = StatsCalculator.perfectCount(students, classExams);
    final delayed = StatsCalculator.delayedCount(students, classExams);
    final passed = classExams.where((e) => e.isPassed).length;
    final failed = classExams.length - passed;
    final now = DateTime.now();
    final dateStr = '${_pad(now.year)}/${_pad(now.month)}/${_pad(now.day)}';

    final studentRows = students.map((s) {
      final studentExams =
          classExams.where((e) => e.studentId == s.id).toList();
      final planAvg = StatsCalculator.studentPlanAchievement(s, studentExams);
      final lastExam = s.lastExam.isEmpty ? 'بداية الطريق' : s.lastExam;
      final lastDate = _formatDate(s.lastExamDate);
      final stats = StatsCalculator.computeCurrent(s);
      final nextExamDate = _formatDate(stats.expectedDate);
      return _StudentRow(
        name: s.name,
        isActive: s.isActive,
        nextExam: _getNextExamName(s),
        nextExamDate: nextExamDate,
        planAvg: planAvg.round(),
        lastExam: lastExam,
        lastDate: lastDate,
        quranCompleted: s.currentExamIndex >= 19,
      );
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection: pw.TextDirection.rtl,
        theme: _regularFont != null
            ? pw.ThemeData.withFont(
                base: _regularFont!,
                bold: _boldFont,
              )
            : null,
        header: (ctx) => _header(dateStr),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => [
          _summarySection(
            className: classData.name,
            total: total,
            active: active,
            suspended: suspended,
            rating: rating.round(),
            avg: avg.round(),
            perfect: perfect,
            delayed: delayed,
            passed: passed,
            failed: failed,
            examsCount: classExams.length,
          ),
          pw.SizedBox(height: 16),
          _studentsTable(studentRows),
          pw.SizedBox(height: 16),
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Text(
              'تم إنشاء هذا التقرير بتاريخ $dateStr',
              style: _ts(size: 8, color: PdfColors.grey600),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(String dateStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'تقرير إنجاز الخطة',
                style: _ts(
                    size: 16,
                    bold: true,
                    color: _pdfColor(AppColors.brandBlue)),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'مؤسسة إتقان للتعليم والتنمية',
                style: _ts(size: 9, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Text(
            dateStr,
            style: _ts(size: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'صفحة ${ctx.pageNumber} من ${ctx.pagesCount}',
            style: _ts(size: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _summarySection({
    required String className,
    required int total,
    required int active,
    required int suspended,
    required int rating,
    required int avg,
    required int perfect,
    required int delayed,
    required int passed,
    required int failed,
    required int examsCount,
  }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _pdfColor(AppColors.brandTeal).shade(0.92),
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(
                      'الحلقة: ',
                      style: _ts(size: 11, color: PdfColors.white),
                    ),
                    pw.Text(
                      className,
                      style: _ts(size: 13, bold: true, color: PdfColors.white),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'عدد الطلاب: $total  (نشط: $active، موقوف: $suspended)',
                  style: _ts(size: 9, color: PdfColors.white),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'إحصائيات الحلقة',
            style: _ts(
                size: 11, bold: true, color: _pdfColor(AppColors.brandBlue)),
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              _statBox('التقييم', '$rating%', PdfColors.green700),
              pw.SizedBox(width: 5),
              _statBox('المتوسط', '$avg%', PdfColors.blue700),
              pw.SizedBox(width: 5),
              _statBox('مكتمل 100%', '$perfect', PdfColors.teal700),
              pw.SizedBox(width: 5),
              _statBox('متأخر', '$delayed', PdfColors.red700),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              _statBox('اختبارات ناجحة', '$passed', PdfColors.green600),
              pw.SizedBox(width: 5),
              _statBox('اختبارات راسبة', '$failed', PdfColors.red600),
              pw.SizedBox(width: 5),
              _statBox('إجمالي', '$examsCount', PdfColors.grey700),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: _ts(size: 13, bold: true, color: color),
            ),
            pw.SizedBox(height: 1),
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Text(
                label,
                style: _ts(size: 7, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _studentsTable(List<_StudentRow> rows) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'تفاصيل الطلاب',
            style: _ts(
                size: 12, bold: true, color: _pdfColor(AppColors.brandBlue)),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
            columnWidths: const {
              0: pw.FixedColumnWidth(24),
              1: pw.FlexColumnWidth(2.5),
              2: pw.FixedColumnWidth(42),
              3: pw.FlexColumnWidth(2),
              4: pw.FixedColumnWidth(48),
              5: pw.FixedColumnWidth(42),
              6: pw.FlexColumnWidth(1.8),
              7: pw.FixedColumnWidth(65),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: _pdfColor(AppColors.brandTeal).shade(0.85),
                ),
                children: [
                  _thCell('التاريخ'),
                  _thCell('آخر نجاح'),
                  _thCell('إنجاز الخطة'),
                  _thCell('تاريخ المتوقع'),
                  _thCell('الاختبار القادم'),
                  _thCell('الحالة'),
                  _thCell('الاسم'),
                  _thCell('#'),
                ],
              ),
              ...rows.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven ? PdfColors.white : PdfColors.grey100,
                  ),
                  children: [
                    _tdCell(r.lastDate),
                    _tdCell(r.lastExam),
                    _tdCell('${r.planAvg}%', color: _gradeColor(r.planAvg)),
                    _tdCell(r.nextExamDate),
                    _tdCell(r.nextExam),
                    _tdCell(
                      r.quranCompleted
                          ? '✓ ختم'
                          : (r.isActive ? 'نشط' : 'موقوف'),
                      color: r.quranCompleted
                          ? PdfColors.green700
                          : (r.isActive
                              ? PdfColors.blue700
                              : PdfColors.grey700),
                    ),
                    _tdCell(r.name, bold: true),
                    _tdCell('${i + 1}'),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _thCell(String text) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        color: _pdfColor(AppColors.brandTeal).shade(0.85),
        child: pw.Text(
          text,
          style: _ts(size: 9, bold: true, color: PdfColors.white),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static pw.Widget _tdCell(String text, {bool bold = false, PdfColor? color}) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        child: pw.Text(
          text,
          style: _ts(
            size: 8,
            bold: bold,
            color: color ?? PdfColors.grey900,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static PdfColor _gradeColor(int pct) {
    if (pct >= 95) return PdfColors.green700;
    if (pct >= 85) return PdfColors.green500;
    if (pct >= 79) return PdfColors.amber700;
    return PdfColors.red700;
  }

  static PdfColor _pdfColor(Color c) {
    return PdfColor(c.r, c.g, c.b);
  }

  static String _pad(int n) => n < 10 ? '0$n' : '$n';

  static String _formatDate(DateTime d) =>
      '${d.year}-${_pad(d.month)}-${_pad(d.day)}';

  static String _getNextExamName(StudentModel s) {
    if (s.currentExamIndex >= 19) return 'كامل القرآن ✓';
    const names = [
      'رشيدي مرحلي',
      'رشيدي نهائي',
      'التأهيلية (1+2)',
      '3+4',
      'المرحلة 1 (1-6)',
      '7+8',
      '9+10',
      'المرحلة 2 (7-12)',
      '13+14',
      '15+16',
      'المرحلة 3 (13-18)',
      '19+20',
      '21+22',
      'المرحلة 4 (19-24)',
      '25+26',
      '27+28',
      'المرحلة 5 (25-30)',
      'كامل القرآن',
      'ختم',
    ];
    final i = s.currentExamIndex.clamp(0, names.length - 1);
    return names[i];
  }

  static Future<void> sharePdf(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);

    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
      return;
    } catch (e) {
      debugPrint(
          'Printing.sharePdf failed: $e, falling back to Share.shareXFiles');
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          text: 'تقرير إنجاز الخطة',
        ),
      );
    } catch (e) {
      debugPrint('SharePlus.instance.share failed: $e');
      rethrow;
    }
  }

  static Future<File> savePdf(Uint8List bytes, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}

class _StudentRow {
  final String name;
  final bool isActive;
  final String nextExam;
  final String nextExamDate;
  final int planAvg;
  final String lastExam;
  final String lastDate;
  final bool quranCompleted;

  _StudentRow({
    required this.name,
    required this.isActive,
    required this.nextExam,
    required this.nextExamDate,
    required this.planAvg,
    required this.lastExam,
    required this.lastDate,
    required this.quranCompleted,
  });
}
