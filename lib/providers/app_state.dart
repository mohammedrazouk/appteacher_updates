import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/class_model.dart';
import '../data/models/exam_model.dart';
import '../data/models/student_model.dart';
import '../data/repository/app_repository.dart';

class AppState extends ChangeNotifier {
  final _repo = AppRepository.instance;

  List<ClassModel> _classes = [];
  List<StudentModel> _students = [];
  List<ExamModel> _exams = [];
  List<ExamModel> _classExams = [];

  List<ClassModel> get classes => _classes;
  List<StudentModel> get students => _students;
  List<ExamModel> get exams => _exams;
  List<ExamModel> get classExams => _classExams;

  DateTime _lastTickDay = _dayOnly(DateTime.now());
  Timer? _dayTimer;

  AppState() {
    _startDayWatcher();
  }

  static DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  void _startDayWatcher() {
    _dayTimer?.cancel();
    _dayTimer = Timer.periodic(const Duration(hours: 1), (_) {
      final today = _dayOnly(DateTime.now());
      if (today != _lastTickDay) {
        _lastTickDay = today;
        notifyListeners();
      }
    });
  }

  Future<void> loadClasses() async {
    _classes = await _repo.getAllClasses();
    notifyListeners();
  }

  Future<void> addClass(String name, String teacherName) async {
    await _repo.insertClass(ClassModel(name: name, teacherName: teacherName));
    await loadClasses();
  }

  Future<void> deleteClass(int classId) async {
    await _repo.deleteClass(classId);
    await loadClasses();
  }

  Future<void> loadStudents(int classId) async {
    _students = await _repo.getStudentsByClass(classId);
    _classExams = await _repo.getExamsByClass(classId);
    notifyListeners();
  }

  Future<void> loadActiveStudents(int classId) async {
    _students = await _repo.getActiveStudentsByClass(classId);
    _classExams = await _repo.getExamsByClass(classId);
    notifyListeners();
  }

  Future<void> toggleStudentActive(StudentModel student) async {
    await _repo.toggleStudentActive(student.id!, student.classId);
    await loadStudents(student.classId);
  }

  Future<void> addStudent(StudentModel student) async {
    await _repo.insertStudent(student);
    await loadStudents(student.classId);
  }

  Future<void> deleteStudent(int studentId, int classId) async {
    await _repo.deleteStudent(studentId);
    await loadStudents(classId);
  }

  Future<void> deleteAllStudents(int classId) async {
    await _repo.deleteAllStudentsInClass(classId);
    await loadStudents(classId);
  }

  Future<void> recordExam(
      StudentModel student, DateTime actualDate, double grade, String? notes) async {
    await _repo.recordExam(student, actualDate, grade, notes);
    await loadStudents(student.classId);
  }

  Future<void> loadExams(int studentId) async {
    _exams = await _repo.getExamsByStudent(studentId);
    notifyListeners();
  }

  Future<void> deleteExam(int examId, StudentModel student) async {
    await _repo.deleteExam(examId, student);
    await loadStudents(student.classId);
    await loadExams(student.id!);
  }

  @override
  void dispose() {
    _dayTimer?.cancel();
    super.dispose();
  }
}
