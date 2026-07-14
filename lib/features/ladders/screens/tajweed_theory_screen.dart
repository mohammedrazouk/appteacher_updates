import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/errors_data.dart';
import '../data/grade_calculator.dart';
import '../data/storage_helper.dart';
import '../models/ladder_result.dart';
import 'evaluation_board_screen.dart';

class TajweedTheoryScreen extends StatefulWidget {
  final String studentName;
  final int stageIndex;

  const TajweedTheoryScreen({
    super.key,
    required this.studentName,
    required this.stageIndex,
  });

  @override
  State<TajweedTheoryScreen> createState() => _TajweedTheoryScreenState();
}

class _TajweedTheoryScreenState extends State<TajweedTheoryScreen> {
  static const double _totalMarks = 10;
  static const double _passMarks = 7;
  static const double _deductionPerPress = 0.5;

  int _count = 0;
  bool _saving = false;

  double get _totalDeduction => _count * _deductionPerPress;
  double get _score => _totalMarks - _totalDeduction;
  bool get _isPass => _score >= _passMarks;

  void _increment() {
    setState(() => _count++);
  }

  void _decrement() {
    if (_count > 0) setState(() => _count--);
  }

  void _proceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationBoardScreen(
          studentName: widget.studentName,
          stageIndex: widget.stageIndex,
          tajweedTheoryDeduction: _totalDeduction,
          tajweedTheoryScore: _score,
        ),
      ),
    );
  }

  Future<void> _saveFailedResult() async {
    if (_saving) return;
    setState(() => _saving = true);
    final totalDeductions = 100 - _score * 10;
    final grade = computeGradeFromDeductions(totalDeductions);
    await LadderStorage.saveResult(
      LadderResult(
        id: generateId(),
        studentName: widget.studentName,
        stage: stages[widget.stageIndex],
        errors: [
          ErrorEntry(name: 'التجويد النظري (راسب)', count: _count),
        ],
        totalDeductions: totalDeductions,
        grade: grade,
        timestamp: DateTime.now(),
      ),
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ نتيجة الرسوب بنجاح')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'التجويد النظري',
          style: TextStyle(
            color: AppColors.brandBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          widget.studentName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.menu_book,
                            size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'الاختبار: ${_stageName()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'علامة النجاح: $_passMarks من $_totalMarks',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _increment,
                onLongPress: _count > 0 ? _decrement : null,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _count > 0
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _count > 0
                          ? const Color(0xFFFECACA)
                          : const Color(0xFFFECDD3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 48,
                        color: const Color(0xFFBE123C),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'التجويد النظري',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'اضغط للخصم - $_deductionPerPress لكل ضغطة',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFBE123C).withValues(alpha: 0.7),
                        ),
                      ),
                      if (_count > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _decrement,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Icon(Icons.remove,
                                      size: 30, color: Color(0xFFEF4444)),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 22,
                                color: const Color(0xFFFECACA),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  '-${_formatDeduction(_totalDeduction)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFBE123C),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 22,
                                color: const Color(0xFFFECACA),
                              ),
                              GestureDetector(
                                onTap: _increment,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Icon(Icons.add,
                                      size: 30, color: Color(0xFF10B981)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isPass
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isPass
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'النتيجة: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isPass
                            ? const Color(0xFF065F46)
                            : const Color(0xFFBE123C),
                      ),
                    ),
                    Text(
                      '${_formatDeduction(_score)} / $_totalMarks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isPass
                            ? const Color(0xFF065F46)
                            : const Color(0xFFBE123C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isPass
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isPass ? 'ناجح' : 'راسب',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isPass ? _proceed : null,
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  label: const Text(
                    'الانتقال لسلم الاختبار',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandTeal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (!_isPass) ...[
                const SizedBox(height: 10),
                Text(
                  'الطالب راسب في التجويد النظري، لا يمكن الانتقال للسلم',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFFBE123C),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _saveFailedResult,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save, size: 20),
                    label: Text(
                      _saving ? 'جاري الحفظ...' : 'حفظ النتيجة',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE123C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _stageName() {
    const names = [
      'رشيدي مرحلي',
      'رشيدي نهائي',
      'المرحلة التأهيلية (1+2)',
      '3+4',
      'المرحلة الأولى (1-6)',
      '7+8',
      '9+10',
      'المرحلة الثانية (7-12)',
      '13+14',
      '15+16',
      'المرحلة الثالثة (13-18)',
      '19+20',
      '21+22',
      'المرحلة الرابعة (19-24)',
      '25+26',
      '27+28',
      'المرحلة الخامسة (25-30)',
      'كامل القرآن',
    ];
    return names[widget.stageIndex.clamp(0, names.length - 1)];
  }

  String _formatDeduction(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}
