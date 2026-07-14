class ClassModel {
  final int? id;
  final String name;
  final String teacherName;

  ClassModel({
    this.id,
    required this.name,
    this.teacherName = '',
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'teacherName': teacherName};
  }

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      teacherName: (map['teacherName'] as String?) ?? '',
    );
  }

  ClassModel copyWith({int? id, String? name, String? teacherName}) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
    );
  }
}
