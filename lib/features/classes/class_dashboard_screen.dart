import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/exam_sequence.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/class_model.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/student_model.dart';
import '../../data/logic/stats_calculator.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/percentage_circle.dart';
import '../students/student_details_screen.dart';
import 'services/report_service.dart';

class ClassDashboardScreen extends StatefulWidget {
  final int classId;

  const ClassDashboardScreen({super.key, required this.classId});

  @override
  State<ClassDashboardScreen> createState() => _ClassDashboardScreenState();
}

class _ClassDashboardScreenState extends State<ClassDashboardScreen> {
  String _className = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      state.loadStudents(widget.classId);
      final cls = state.classes.firstWhere((c) => c.id == widget.classId);
      setState(() => _className = cls.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allStudents = context.watch<AppState>().students;
    final students = allStudents;
    final studentsForRating = allStudents;
    final suspendedCount = allStudents.where((s) => !s.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_className.isEmpty ? 'الحلقة' : _className),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير التقرير',
            onPressed: () => _exportReport(),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'إضافة طالب',
            onPressed: () => _showAddStudentDialog(context),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final classExams = context.watch<AppState>().classExams;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildStats(studentsForRating, classExams)),
              SliverToBoxAdapter(child: _buildExamStats(classExams, studentsForRating)),
              SliverToBoxAdapter(child: _buildStudentsHeader()),
              if (students.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: AppColors.divider),
                        SizedBox(height: 16),
                        Text('لا يوجد طلاب', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildStudentCard(students[index], classExams),
                      childCount: students.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportReport() async {
    final state = context.read<AppState>();
    final classData = state.classes.firstWhere(
      (c) => c.id == widget.classId,
      orElse: () => ClassModel(id: widget.classId, name: _className),
    );
    final students = state.students;
    final classExams = state.classExams;

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد طلاب لتصدير التقرير')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final bytes = await ReportService.generateClassReport(
        classData: classData,
        students: students,
        classExams: classExams,
      );

      if (!mounted) return;
      Navigator.pop(context);

      final filename =
          'تقرير_${classData.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await ReportService.sharePdf(bytes, filename);
    } catch (e, st) {
      debugPrint('Export report error: $e\n$st');
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إنشاء التقرير: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Widget _buildSuspendedBanner(int count) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.pause_circle_filled, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'يوجد $count طالب موقوف - لا يدخل في إحصائيات الأداء',
              style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<StudentModel> students, List<ExamModel> classExams) {
    final rating = StatsCalculator.classRating(students, classExams);
    final avg = StatsCalculator.classAverage(students, classExams);
    final perfect = StatsCalculator.perfectCount(students, classExams);
    final delayed = StatsCalculator.delayedCount(students, classExams);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: StatCard(label: 'التقييم', value: '${rating.round()}%')),
              const SizedBox(width: 8),
              Expanded(child: StatCard(label: 'المتوسط', value: '${avg.round()}%')),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'مكتمل 100%',
                  value: '$perfect',
                  valueColor: AppColors.brandTeal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'متأخر',
                  value: '$delayed',
                  valueColor: AppColors.statusRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamStats(List<ExamModel> exams, List<StudentModel> students) {
    final successCount = StatsCalculator.successfulExamsCount(exams);
    final failCount = StatsCalculator.failedExamsCount(exams);
    final rate = StatsCalculator.successRate(exams);
    final avgGrade = StatsCalculator.averageSuccessfulGrade(exams);
    final rateColor = AppTheme.percentageColor(rate);
    final classRating = StatsCalculator.classRating(students, exams);
    final finalScore =
        StatsCalculator.finalRating(
      classRating: classRating,
      successRate: rate,
      avgSuccessfulGrade: avgGrade,
    );
    final finalColor = AppTheme.percentageColor(finalScore);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'إحصائيات الاختبارات',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.brandBlue,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'ناجح',
                  value: '$successCount',
                  valueColor: AppColors.brandTeal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'راسب',
                  value: '$failCount',
                  valueColor: AppColors.statusRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'نسبة النجاح',
                  value: '${rate.round()}%',
                  valueColor: rateColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'متوسط الناجحين',
                  value: avgGrade > 0 ? avgGrade.toStringAsFixed(1) : '-',
                  valueColor: AppColors.brandBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFinalRatingCard(finalScore, finalColor),
        ],
      ),
    );
  }

  Widget _buildFinalRatingCard(double score, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'النتيجة النهائية للتقييم',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '(التقييم + نسبة النجاح + متوسط الناجحين) ÷ 3',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${score.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsHeader() {
    final state = context.watch<AppState>();
    final total = state.students.length;
    final active = state.students.where((s) => s.isActive).length;
    final suspended = total - active;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'الطلاب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandBlue,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$active',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.brandTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (suspended > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$suspended موقوف',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete_sweep, size: 20),
            label: const Text('حذف الجميع'),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusRed),
            onPressed: () => _showDeleteAllConfirm(),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentModel student, List<ExamModel> classExams) {
    final stats = StatsCalculator.computeCurrent(student);
    final studentExams =
        classExams.where((e) => e.studentId == student.id).toList();
    final planAvg =
        StatsCalculator.studentPlanAchievement(student, studentExams);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailsScreen(student: student),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                PercentageCircle(percentage: planAvg),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              student.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: student.isActive
                                    ? AppColors.brandBlue
                                    : Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!student.isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'موقوف',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats.quranCompleted
                            ? 'ختم القرآن الكريم'
                            : 'القادم: ${stats.nextExamName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: student.isActive
                              ? AppColors.textSecondary
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                _StudentMenu(student: student, classId: widget.classId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddStudentDialog(classId: widget.classId),
    );
  }

  void _showDeleteAllConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('سيتم حذف جميع طلاب الحلقة. هل أنت متأكد؟'),
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
              context.read<AppState>().deleteAllStudents(widget.classId);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _StudentMenu extends StatelessWidget {
  final StudentModel student;
  final int classId;

  const _StudentMenu({required this.student, required this.classId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.statusRed, size: 20),
              SizedBox(width: 8),
              Text('حذف الطالب'),
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
              content: Text('حذف الطالب "${student.name}"؟'),
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
                    context.read<AppState>().deleteStudent(student.id!, classId);
                    Navigator.pop(ctx);
                  },
                  child: const Text('حذف'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class AddStudentDialog extends StatefulWidget {
  final int classId;

  const AddStudentDialog({super.key, required this.classId});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _nameController = TextEditingController();
  StudentType _type = StudentType.rashidiNew;
  int _selectedExamIndex = 0;
  DateTime _lastExamDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة طالب'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الطالب'),
                validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<StudentType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'نوع الطالب'),
                items: const [
                  DropdownMenuItem(
                      value: StudentType.rashidiNew, child: Text('رشيدي جديد')),
                  DropdownMenuItem(
                      value: StudentType.safaraNew, child: Text('سفرة جديد')),
                  DropdownMenuItem(
                      value: StudentType.continuing, child: Text('مستمر')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              if (_type == StudentType.rashidiNew ||
                  _type == StudentType.safaraNew) ...[
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _formatDate(_startDate)),
                  decoration: const InputDecoration(
                    labelText: 'تاريخ البدء',
                    suffixIcon: Icon(Icons.calendar_today, color: AppColors.brandTeal),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              if (_type == StudentType.continuing) ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedExamIndex,
                  decoration:
                      const InputDecoration(labelText: 'آخر اختبار ناجح'),
                  items: List.generate(
                    ExamSequence.lastIndex,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(ExamSequence.nameAt(i)),
                    ),
                  ),
                  onChanged: (v) => setState(() => _selectedExamIndex = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _formatDate(_lastExamDate)),
                  decoration: const InputDecoration(
                    labelText: 'تاريخ آخر اختبار',
                    suffixIcon: Icon(Icons.calendar_today, color: AppColors.brandTeal),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _lastExamDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _lastExamDate = picked;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  void _submit() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final name = _nameController.text.trim();
    final now = DateTime.now();

    StudentModel student;
    switch (_type) {
      case StudentType.rashidiNew:
        student = StudentModel(
          classId: widget.classId,
          name: name,
          type: StudentType.rashidiNew,
          joinDate: _startDate,
          lastExam: '',
          lastExamDate: _startDate,
          currentExamIndex: 0,
          initialExamIndex: 0,
          initialExamDate: _startDate,
        );
        break;
      case StudentType.safaraNew:
        student = StudentModel(
          classId: widget.classId,
          name: name,
          type: StudentType.safaraNew,
          joinDate: _startDate,
          lastExam: 'رشيدي نهائي',
          lastExamDate: _startDate,
          currentExamIndex: 2,
          initialExamIndex: 2,
          initialExamDate: _startDate,
        );
        break;
      case StudentType.continuing:
        student = StudentModel(
          classId: widget.classId,
          name: name,
          type: StudentType.continuing,
          joinDate: _lastExamDate,
          lastExam: ExamSequence.nameAt(_selectedExamIndex),
          lastExamDate: _lastExamDate,
          currentExamIndex: _selectedExamIndex + 1,
          initialExamIndex: _selectedExamIndex + 1,
          initialExamDate: _lastExamDate,
        );
        break;
    }

    context.read<AppState>().addStudent(student);
    Navigator.pop(context);
  }

  String _formatDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
}
