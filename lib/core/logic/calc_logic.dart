class CalcLogic {
  CalcLogic._();

  static DateTime _toMidnight(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  static DateTime expectedDate(DateTime lastExamDate, double nextDurationDays) {
    final base = _toMidnight(lastExamDate);
    return base.add(Duration(days: nextDurationDays.round()));
  }

  static double calcPercentage({
    required DateTime lastExamDate,
    required double examDuration,
    required DateTime referenceDate,
  }) {
    final expected = expectedDate(lastExamDate, examDuration);
    final reference = _toMidnight(referenceDate);

    if (!reference.isAfter(expected)) {
      return 100.0;
    }

    final delayDays = reference.difference(expected).inDays;
    final actualDuration = examDuration + delayDays;
    if (actualDuration <= 0) return 100.0;
    return (examDuration / actualDuration) * 100;
  }

  static double average(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sum = values.fold<double>(0.0, (a, b) => a + b);
    return sum / values.length;
  }

  static double classRating(List<double> studentPercentages) {
    if (studentPercentages.isEmpty) return 0.0;
    final perfectCount =
        studentPercentages.where((p) => p >= 100).length;
    if (perfectCount >= 14) return 100.0;
    return average(studentPercentages);
  }
}
