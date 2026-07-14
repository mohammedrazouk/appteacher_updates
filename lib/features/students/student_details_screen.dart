import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/exam_sequence.dart';
import '../../core/theme/app_theme.dart';
import '../../data/logic/stats_calculator.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/student_model.dart';
import '../../providers/app_state.dart';
import '../../shared/utils/date_formatter.dart';
import '../../shared/widgets/percentage_circle.dart';

class StudentDetailsScreen extends StatefulWidget {
  final StudentModel student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  late StudentModel _student;
  DateTime _selectedDate = DateTime.now();
  final _gradeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showExamForm = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadExams(widget.student.id!);
    });
  }

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  void _toggleExamForm() {
    setState(() {
      _showExamForm = !_showExamForm;
      if (_showExamForm) {
        _selectedDate = DateTime.now();
        _gradeController.clear();
      }
    });
  }

  void _refreshStudent() {
    final state = context.read<AppState>();
    final updated = state.students.firstWhere(
      (s) => s.id == widget.student.id,
      orElse: () => _student,
    );
    setState(() {
      _student = updated;
      _gradeController.clear();
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _recordExam() async {
    if (_isRecording) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isRecording = true);

    final grade = double.parse(_gradeController.text.trim());

    final state = context.read<AppState>();
    await state.recordExam(_student, _selectedDate, grade, null);
    await state.loadExams(_student.id!);
    if (!mounted) return;
    _refreshStudent();
    setState(() {
      _showExamForm = false;
      _gradeController.clear();
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exams = context.watch<AppState>().exams;
    final stats = StatsCalculator.computeCurrent(_student);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(_student.name, overflow: TextOverflow.ellipsis)),
            if (!_student.isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'موقوف',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _student.isActive ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: _student.isActive ? Colors.orange.shade700 : Colors.green.shade700,
              size: 28,
            ),
            tooltip: _student.isActive ? 'إيقاف الطالب' : 'تنشيط الطالب',
            onPressed: () => _toggleActive(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_student.isActive) _buildSuspendedBanner(),
            if (!_student.isActive) const SizedBox(height: 16),
            _buildStatusCard(stats),
            const SizedBox(height: 16),
            _buildPlanAchievementCard(exams),
            const SizedBox(height: 16),
            if (!stats.quranCompleted) _buildExamRecorder(stats),
            const SizedBox(height: 16),
            _buildExamHistory(exams),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActive() async {
    final state = context.read<AppState>();
    final isActive = _student.isActive;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isActive ? 'إيقاف الطالب' : 'تنشيط الطالب'),
        content: Text(
          isActive
              ? 'هل تريد إيقاف ${_student.name}؟\nسيبقى اسمه في البرنامج لكن لن يظهر في القائمة الرئيسية.'
              : 'هل تريد إعادة تنشيط ${_student.name}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'إيقاف' : 'تنشيط'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await state.toggleStudentActive(_student);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isActive ? 'تم إيقاف الطالب' : 'تم تنشيط الطالب',
          ),
        ),
      );
    }
  }

  Widget _buildSuspendedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.pause_circle_filled, color: Colors.red.shade700, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطالب موقوف',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'لا يظهر في قائمة الطلاب الرئيسية. اضغط زر التشغيل لإعادة تنشيطه.',
                  style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(StudentStats stats) {
    final color = AppTheme.percentageColor(stats.currentPercentage);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            PercentageCircle(percentage: stats.currentPercentage, size: 80),
            const SizedBox(height: 16),
            if (stats.quranCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.brandLime.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration, color: AppColors.brandLime),
                    SizedBox(width: 8),
                    Text(
                      'ختم القرآن الكريم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _InfoRow(label: 'الاختبار القادم', value: stats.nextExamName),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'النسبة الحالية',
                value: '${stats.currentPercentage.round()}%',
                valueColor: color,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'آخر اختبار ناجح',
                value: _student.lastExam.isEmpty
                    ? 'بداية الطريق'
                    : _student.lastExam,
              ),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'تاريخ آخر نجاح',
                value: DateFormatter.format(_student.lastExamDate),
              ),
              const SizedBox(height: 10),
              _InfoRow(
                label: 'التاريخ المتوقع',
                value: DateFormatter.format(stats.expectedDate),
                valueColor: AppColors.brandTeal,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanAchievementCard(List<ExamModel> exams) {
    final planAvg = StatsCalculator.studentPlanAchievement(_student, exams);
    final color = AppTheme.percentageColor(planAvg);
    final successful = exams.where((e) => e.isPassed).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            PercentageCircle(percentage: planAvg, size: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'متوسط تحقيق الخطة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isQuranCompleted(_student)
                        ? 'جميع الاختبارات مجتازة'
                        : 'اختبارات مجتازة: $successful + الاختبار الحالي',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${planAvg.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isQuranCompleted(StudentModel s) {
    return StatsCalculator.computeCurrent(s).quranCompleted;
  }

  Widget _buildExamRecorder(StudentStats stats) {
    if (!_showExamForm) {
      return Card(
        child: InkWell(
          onTap: _toggleExamForm,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.brandTeal, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تسجيل نتيجة',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brandBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الاختبار القادم: ${stats.nextExamName}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle, color: AppColors.brandTeal, size: 28),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.brandTeal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تسجيل نتيجة: ${stats.nextExamName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleExamForm,
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    tooltip: 'إلغاء',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'النجاح من ${ExamSequence.passingGrade.toStringAsFixed(0)} درجة فأكثر',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormatter.format(_selectedDate),
                ),
                decoration: const InputDecoration(
                  labelText: 'التاريخ الفعلي',
                  suffixIcon: Icon(Icons.calendar_today,
                      color: AppColors.brandTeal),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gradeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'الدرجة (من 100)',
                  hintText: 'مثال: 85',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'مطلوب';
                  final grade = double.tryParse(value.trim());
                  if (grade == null) return 'رقم غير صحيح';
                  if (grade < 0 || grade > 100) return 'الدرجة من 0 إلى 100';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleExamForm,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('إلغاء'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isRecording ? null : _recordExam,
                      icon: _isRecording
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save, size: 18),
                      label: Text(
                        _isRecording ? 'جاري الحفظ...' : 'حفظ النتيجة',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamHistory(List<ExamModel> exams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'سجل الاختبارات',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.brandBlue,
          ),
        ),
        const SizedBox(height: 12),
        if (exams.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'لا يوجد اختبارات مسجلة',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          )
        else
          ...exams.reversed.map((exam) => _ExamRecordItem(
                exam: exam,
                student: _student,
                onDelete: () async {
                  final state = context.read<AppState>();
                  await state.deleteExam(exam.id!, _student);
                  if (!mounted) return;
                  _refreshStudent();
                },
              )),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.brandBlue,
          ),
        ),
      ],
    );
  }
}

class _ExamRecordItem extends StatelessWidget {
  final ExamModel exam;
  final StudentModel student;
  final VoidCallback onDelete;

  const _ExamRecordItem({
    required this.exam,
    required this.student,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (exam.isPassed)
                PercentageCircle(percentage: exam.percentage, size: 44)
              else
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(Icons.cancel,
                        color: AppColors.statusRed, size: 28),
                  ),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          exam.examName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandBlue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(isPassed: exam.isPassed),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الدرجة: ${exam.grade.toStringAsFixed(1)} / 100',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: exam.isPassed
                            ? AppColors.brandTeal
                            : AppColors.statusRed,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'متوقع: ${DateFormatter.format(exam.expectedDate)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      'فعلي: ${DateFormatter.format(exam.actualDate)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (exam.notes != null && exam.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ملاحظات: ${exam.notes}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textSecondary),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            color: AppColors.statusRed, size: 20),
                        SizedBox(width: 8),
                        Text('حذف الاختبار'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: Text(
                            'حذف محاولة اختبار "${exam.examName}"؟ سيتم إعادة حساب حالة الطالب.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusRed,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete();
                            },
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPassed;

  const _StatusBadge({required this.isPassed});

  @override
  Widget build(BuildContext context) {
    final color = isPassed ? AppColors.brandTeal : AppColors.statusRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPassed ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isPassed ? 'ناجح' : 'راسب',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
