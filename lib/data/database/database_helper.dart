import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'appteacher.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE students ADD COLUMN initialExamIndex INTEGER NOT NULL DEFAULT 0');
          await db.execute(
              'ALTER TABLE students ADD COLUMN initialExamDate TEXT');
          await db.execute(
              'ALTER TABLE exams ADD COLUMN grade REAL NOT NULL DEFAULT 0');
          await db.execute(
              'ALTER TABLE exams ADD COLUMN isPassed INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE exams ADD COLUMN notes TEXT');
          await db.execute(
              'UPDATE students SET initialExamIndex = currentExamIndex, initialExamDate = lastExamDate');
        }
        if (oldVersion < 3) {
          await db.execute(
              'ALTER TABLE students ADD COLUMN isActive INTEGER NOT NULL DEFAULT 1');
        }
        if (oldVersion < 4) {
          await db.execute(
              'ALTER TABLE classes ADD COLUMN teacherName TEXT NOT NULL DEFAULT \'\'');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        teacherName TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        classId INTEGER NOT NULL,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        joinDate TEXT NOT NULL,
        lastExam TEXT NOT NULL,
        lastExamDate TEXT NOT NULL,
        currentExamIndex INTEGER NOT NULL,
        initialExamIndex INTEGER NOT NULL DEFAULT 0,
        initialExamDate TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        examName TEXT NOT NULL,
        expectedDate TEXT NOT NULL,
        actualDate TEXT NOT NULL,
        duration REAL NOT NULL,
        percentage REAL NOT NULL,
        grade REAL NOT NULL DEFAULT 0,
        isPassed INTEGER NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_students_classId ON students(classId)');
    await db.execute(
        'CREATE INDEX idx_exams_studentId ON exams(studentId)');
  }
}
