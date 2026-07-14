enum StudentType { rashidiNew, safaraNew, continuing }

class StudentModel {
  final int? id;
  final int classId;
  final String name;
  final StudentType type;
  final DateTime joinDate;
  final String lastExam;
  final DateTime lastExamDate;
  final int currentExamIndex;
  final int initialExamIndex;
  final DateTime initialExamDate;
  final bool isActive;

  StudentModel({
    this.id,
    required this.classId,
    required this.name,
    required this.type,
    required this.joinDate,
    required this.lastExam,
    required this.lastExamDate,
    required this.currentExamIndex,
    required this.initialExamIndex,
    required this.initialExamDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'name': name,
      'type': type.index,
      'joinDate': joinDate.toIso8601String(),
      'lastExam': lastExam,
      'lastExamDate': lastExamDate.toIso8601String(),
      'currentExamIndex': currentExamIndex,
      'initialExamIndex': initialExamIndex,
      'initialExamDate': initialExamDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as int?,
      classId: map['classId'] as int,
      name: map['name'] as String,
      type: StudentType.values[map['type'] as int],
      joinDate: DateTime.parse(map['joinDate'] as String),
      lastExam: map['lastExam'] as String,
      lastExamDate: DateTime.parse(map['lastExamDate'] as String),
      currentExamIndex: map['currentExamIndex'] as int,
      initialExamIndex: (map['initialExamIndex'] as int?) ?? map['currentExamIndex'] as int,
      initialExamDate: map['initialExamDate'] != null
          ? DateTime.parse(map['initialExamDate'] as String)
          : DateTime.parse(map['lastExamDate'] as String),
      isActive: (map['isActive'] as int? ?? 1) == 1,
    );
  }

  StudentModel copyWith({
    int? id,
    int? classId,
    String? name,
    StudentType? type,
    DateTime? joinDate,
    String? lastExam,
    DateTime? lastExamDate,
    int? currentExamIndex,
    int? initialExamIndex,
    DateTime? initialExamDate,
    bool? isActive,
  }) {
    return StudentModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      type: type ?? this.type,
      joinDate: joinDate ?? this.joinDate,
      lastExam: lastExam ?? this.lastExam,
      lastExamDate: lastExamDate ?? this.lastExamDate,
      currentExamIndex: currentExamIndex ?? this.currentExamIndex,
      initialExamIndex: initialExamIndex ?? this.initialExamIndex,
      initialExamDate: initialExamDate ?? this.initialExamDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
