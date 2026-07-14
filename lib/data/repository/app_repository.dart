import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/class_model.dart';
import '../models/exam_model.dart';
import '../models/student_model.dart';
import '../logic/stats_calculator.dart';

class AppRepository {
  AppRepository._();
  static final AppRepository instance = AppRepository._();

  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<int> insertClass(ClassModel cls) async {
    final db = await _db;
    return db.insert('classes', cls.toMap());
  }

  Future<List<ClassModel>> getAllClasses() async {
    final db = await _db;
    final maps = await db.query('classes', orderBy: 'id DESC');
    return maps.map((m) => ClassModel.fromMap(m)).toList();
  }

  Future<void> deleteClass(int classId) async {
    final db = await _db;
    final students = await db.query('students',
        where: 'classId = ?', whereArgs: [classId]);
    for (final s in students) {
      final sid = s['id'] as int;
      await db.delete('exams', where: 'studentId = ?', whereArgs: [sid]);
    }
    await db.delete('students', where: 'classId = ?', whereArgs: [classId]);
    await db.delete('classes', where: 'id = ?', whereArgs: [classId]);
  }

  Future<int> insertStudent(StudentModel student) async {
    final db = await _db;
    return db.insert('students', student.toMap());
  }

  Future<List<StudentModel>> getStudentsByClass(int classId) async {
    final db = await _db;
    final maps = await db.query('students',
        where: 'classId = ?', whereArgs: [classId], orderBy: 'id ASC');
    return maps.map((m) => StudentModel.fromMap(m)).toList();
  }

  Future<List<StudentModel>> getActiveStudentsByClass(int classId) async {
    final db = await _db;
    final maps = await db.query('students',
        where: 'classId = ? AND isActive = 1',
        whereArgs: [classId],
        orderBy: 'id ASC');
    return maps.map((m) => StudentModel.fromMap(m)).toList();
  }

  Future<void> toggleStudentActive(int studentId, int classId) async {
    final db = await _db;
    final maps = await db.query('students',
        columns: ['isActive'],
        where: 'id = ?',
        whereArgs: [studentId],
        limit: 1);
    if (maps.isEmpty) return;
    final current = (maps.first['isActive'] as int? ?? 1) == 1;
    final newVal = current ? 0 : 1;
    await db.update(
      'students',
      {'isActive': newVal},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  Future<void> deleteStudent(int studentId) async {
    final db = await _db;
    await db.delete('exams', where: 'studentId = ?', whereArgs: [studentId]);
    await db.delete('students', where: 'id = ?', whereArgs: [studentId]);
  }

  Future<void> deleteAllStudentsInClass(int classId) async {
    final db = await _db;
    final students = await db.query('students',
        where: 'classId = ?', whereArgs: [classId]);
    for (final s in students) {
      final sid = s['id'] as int;
      await db.delete('exams', where: 'studentId = ?', whereArgs: [sid]);
    }
    await db.delete('students', where: 'classId = ?', whereArgs: [classId]);
  }

  Future<StudentModel> recordExam(
    StudentModel student,
    DateTime actualDate,
    double grade,
    String? notes,
  ) async {
    final db = await _db;
    final exam =
        StatsCalculator.buildExamRecord(student, actualDate, grade);
    final examMap = exam.toMap();
    if (notes != null && notes.trim().isNotEmpty) {
      examMap['notes'] = notes.trim();
    }
    await db.insert('exams', examMap);

    StudentModel updated;
    if (exam.isPassed) {
      updated = StatsCalculator.advanceAfterExam(student, actualDate);
      await db.update('students', updated.toMap(),
          where: 'id = ?', whereArgs: [student.id]);
    } else {
      updated = student;
    }
    return updated;
  }

  Future<List<ExamModel>> getExamsByStudent(int studentId) async {
    final db = await _db;
    final maps = await db.query('exams',
        where: 'studentId = ?', whereArgs: [studentId], orderBy: 'id ASC');
    return maps.map((m) => ExamModel.fromMap(m)).toList();
  }

  Future<List<ExamModel>> getExamsByClass(int classId) async {
    final db = await _db;
    final maps = await db.rawQuery('''
      SELECT exams.* FROM exams
      INNER JOIN students ON exams.studentId = students.id
      WHERE students.classId = ?
      ORDER BY exams.id ASC
    ''', [classId]);
    return maps.map((m) => ExamModel.fromMap(m)).toList();
  }

  Future<StudentModel> deleteExam(int examId, StudentModel student) async {
    final db = await _db;

    await db.delete('exams', where: 'id = ?', whereArgs: [examId]);

    final remainingMaps = await db.query('exams',
        where: 'studentId = ?', whereArgs: [student.id], orderBy: 'id ASC');
    final remaining =
        remainingMaps.map((m) => ExamModel.fromMap(m)).toList();

    final updated = StatsCalculator.recalcFromExams(student, remaining);

    await db.update('students', updated.toMap(),
        where: 'id = ?', whereArgs: [student.id]);
    return updated;
  }
}
