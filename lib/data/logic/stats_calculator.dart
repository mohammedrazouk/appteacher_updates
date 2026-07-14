import '../models/exam_model.dart';
import '../models/student_model.dart';
import '../../core/constants/exam_sequence.dart';
import '../../core/logic/calc_logic.dart';

class StudentStats {
  final String nextExamName;
  final DateTime expectedDate;
  final double currentPercentage;
  final bool quranCompleted;

  StudentStats({
    required this.nextExamName,
    required this.expectedDate,
    required this.currentPercentage,
    required this.quranCompleted,
  });
}

class StatsCalculator {
  StatsCalculator._();

  static StudentStats computeCurrent(StudentModel student) {
    if (ExamSequence.isQuranCompleted(student.currentExamIndex)) {
      return StudentStats(
        nextExamName: 'كامل القرآن',
        expectedDate: student.lastExamDate,
        currentPercentage: 100.0,
        quranCompleted: true,
      );
    }

    final nextIndex = student.currentExamIndex;
    final nextName = ExamSequence.nameAt(nextIndex);
    final nextDuration = ExamSequence.durationAt(nextIndex);
    final expected =
        CalcLogic.expectedDate(student.lastExamDate, nextDuration);
    final percentage = CalcLogic.calcPercentage(
      lastExamDate: student.lastExamDate,
      examDuration: nextDuration,
      referenceDate: DateTime.now(),
    );

    return StudentStats(
      nextExamName: nextName,
      expectedDate: expected,
      currentPercentage: percentage,
      quranCompleted: false,
    );
  }

  static double currentPercentage(StudentModel student) {
    return computeCurrent(student).currentPercentage;
  }

  static List<ExamModel> _studentExams(
      StudentModel student, List<ExamModel> classExams) {
    return classExams.where((e) => e.studentId == student.id).toList();
  }

  static double studentPlanAchievement(
      StudentModel student, List<ExamModel> studentExams) {
    final successful = studentExams.where((e) => e.isPassed).toList();

    if (ExamSequence.isQuranCompleted(student.currentExamIndex)) {
      if (successful.isEmpty) return 100.0;
      final sum = successful.fold<double>(0.0, (a, e) => a + e.percentage);
      return (sum / successful.length).clamp(0.0, 100.0);
    }

    final isSuspended = !student.isActive;
    final useOnlyPast = isSuspended;

    if (useOnlyPast) {
      if (successful.isEmpty) return 0.0;
      final sum = successful.fold<double>(0.0, (a, e) => a + e.percentage);
      return (sum / successful.length).clamp(0.0, 100.0);
    }

    final currentPct = currentPercentage(student);
    if (successful.isEmpty) return currentPct.clamp(0.0, 100.0);
    final sum =
        successful.fold<double>(0.0, (a, e) => a + e.percentage) + currentPct;
    final count = successful.length + 1;
    return (sum / count).clamp(0.0, 100.0);
  }

  static List<double> _classPlanAchievements(
      List<StudentModel> students, List<ExamModel> classExams) {
    return students
        .map((s) => studentPlanAchievement(s, _studentExams(s, classExams)))
        .toList();
  }

  static double classAverage(
      List<StudentModel> students, List<ExamModel> classExams) {
    return CalcLogic.average(_classPlanAchievements(students, classExams));
  }

  static double classRating(
      List<StudentModel> students, List<ExamModel> classExams) {
    return CalcLogic.classRating(_classPlanAchievements(students, classExams));
  }

  static int perfectCount(
      List<StudentModel> students, List<ExamModel> classExams) {
    final pcts = _classPlanAchievements(students, classExams);
    return pcts.where((p) => p >= 100).length;
  }

  static int delayedCount(
      List<StudentModel> students, List<ExamModel> classExams) {
    final pcts = _classPlanAchievements(students, classExams);
    return pcts.where((p) => p < 100).length;
  }

  static int successfulExamsCount(List<ExamModel> exams) {
    return exams.where((e) => e.isPassed).length;
  }

  static int failedExamsCount(List<ExamModel> exams) {
    return exams.where((e) => !e.isPassed).length;
  }

  static double successRate(List<ExamModel> exams) {
    if (exams.isEmpty) return 0.0;
    return (successfulExamsCount(exams) / exams.length) * 100;
  }

  static double averageSuccessfulGrade(List<ExamModel> exams) {
    final successful = exams.where((e) => e.isPassed).toList();
    if (successful.isEmpty) return 0.0;
    final sum = successful.fold<double>(0.0, (a, e) => a + e.grade);
    return sum / successful.length;
  }

  static double finalRating({
    required double classRating,
    required double successRate,
    required double avgSuccessfulGrade,
  }) {
    return (classRating + successRate + avgSuccessfulGrade) / 3;
  }

  static ExamModel buildExamRecord(
    StudentModel student,
    DateTime actualDate,
    double grade,
  ) {
    final nextIndex = student.currentExamIndex;
    final nextName = ExamSequence.nameAt(nextIndex);
    final nextDuration = ExamSequence.durationAt(nextIndex);
    final expected =
        CalcLogic.expectedDate(student.lastExamDate, nextDuration);
    final isPassed = grade >= ExamSequence.passingGrade;

    final percentage = isPassed
        ? CalcLogic.calcPercentage(
            lastExamDate: student.lastExamDate,
            examDuration: nextDuration,
            referenceDate: actualDate,
          )
        : 0.0;

    return ExamModel(
      studentId: student.id!,
      examName: nextName,
      expectedDate: expected,
      actualDate: actualDate,
      duration: nextDuration,
      percentage: percentage,
      grade: grade,
      isPassed: isPassed,
    );
  }

  static StudentModel advanceAfterExam(
      StudentModel student, DateTime actualDate) {
    final nextIndex = student.currentExamIndex;
    final nextName = ExamSequence.nameAt(nextIndex);
    return student.copyWith(
      lastExam: nextName,
      lastExamDate: actualDate,
      currentExamIndex: nextIndex + 1,
    );
  }

  static int examIndexByName(String name) {
    for (int i = 0; i < ExamSequence.steps.length; i++) {
      if (ExamSequence.steps[i].name == name) return i;
    }
    return 0;
  }

  static StudentModel restoreInitial(StudentModel student) {
    final initialIndex = student.initialExamIndex;
    final initialDate = student.initialExamDate;
    final lastExamName =
        initialIndex > 0 ? ExamSequence.nameAt(initialIndex - 1) : '';

    return student.copyWith(
      lastExam: lastExamName,
      lastExamDate: initialDate,
      currentExamIndex: initialIndex,
    );
  }

  static StudentModel recalcFromExams(
      StudentModel student, List<ExamModel> allExams) {
    if (allExams.isEmpty) {
      return restoreInitial(student);
    }

    final successful = allExams.where((e) => e.isPassed).toList();

    if (successful.isEmpty) {
      return restoreInitial(student);
    }

    final lastSuccess = successful.last;
    final nextIndex = examIndexByName(lastSuccess.examName) + 1;

    return student.copyWith(
      lastExam: lastSuccess.examName,
      lastExamDate: lastSuccess.actualDate,
      currentExamIndex: nextIndex,
    );
  }
}
