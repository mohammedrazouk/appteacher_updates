class ExamModel {
  final int? id;
  final int studentId;
  final String examName;
  final DateTime expectedDate;
  final DateTime actualDate;
  final double duration;
  final double percentage;
  final double grade;
  final bool isPassed;
  final String? notes;

  ExamModel({
    this.id,
    required this.studentId,
    required this.examName,
    required this.expectedDate,
    required this.actualDate,
    required this.duration,
    required this.percentage,
    required this.grade,
    required this.isPassed,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'examName': examName,
      'expectedDate': expectedDate.toIso8601String(),
      'actualDate': actualDate.toIso8601String(),
      'duration': duration,
      'percentage': percentage,
      'grade': grade,
      'isPassed': isPassed ? 1 : 0,
      'notes': notes,
    };
  }

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    return ExamModel(
      id: map['id'] as int?,
      studentId: map['studentId'] as int,
      examName: map['examName'] as String,
      expectedDate: DateTime.parse(map['expectedDate'] as String),
      actualDate: DateTime.parse(map['actualDate'] as String),
      duration: (map['duration'] as num).toDouble(),
      percentage: (map['percentage'] as num).toDouble(),
      grade: (map['grade'] as num?)?.toDouble() ?? 0,
      isPassed: ((map['isPassed'] as int?) ?? 0) == 1,
      notes: map['notes'] as String?,
    );
  }
}
