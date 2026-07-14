class ErrorEntry {
  final String name;
  final int count;

  ErrorEntry({required this.name, required this.count});

  Map<String, dynamic> toJson() => {'name': name, 'count': count};

  factory ErrorEntry.fromJson(Map<String, dynamic> json) => ErrorEntry(
        name: json['name'] as String,
        count: json['count'] as int,
      );
}

class LadderResult {
  final String id;
  final String studentName;
  final String stage;
  final List<ErrorEntry> errors;
  final double totalDeductions;
  final String grade;
  final DateTime timestamp;

  LadderResult({
    required this.id,
    required this.studentName,
    required this.stage,
    required this.errors,
    required this.totalDeductions,
    required this.grade,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentName': studentName,
        'stage': stage,
        'errors': errors.map((e) => e.toJson()).toList(),
        'totalDeductions': totalDeductions,
        'grade': grade,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LadderResult.fromJson(Map<String, dynamic> json) => LadderResult(
        id: json['id'] as String,
        studentName: json['studentName'] as String,
        stage: json['stage'] as String,
        errors: (json['errors'] as List)
            .map((e) => ErrorEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalDeductions: (json['totalDeductions'] as num).toDouble(),
        grade: json['grade'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class ErrorButton {
  final String id;
  final String name;
  final double deduction;
  final bool onceOnly;
  final int section;
  final int colorGroup;

  const ErrorButton({
    required this.id,
    required this.name,
    required this.deduction,
    this.onceOnly = false,
    required this.section,
    this.colorGroup = 0,
  });
}
