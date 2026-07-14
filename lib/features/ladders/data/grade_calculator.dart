const double totalMarks = 100;
const double passMarks = 79;

double computeFinalScore(double totalDeductions) {
  final score = totalMarks - totalDeductions;
  return score < 0 ? 0 : score;
}

String computeGrade(double finalScore) {
  if (finalScore < passMarks) return 'إعادة';
  if (finalScore < 85) return 'جيد';
  if (finalScore < 90) return 'جيد جداً';
  if (finalScore < 95) return 'ممتاز';
  return 'تفوق';
}

String computeGradeFromDeductions(double totalDeductions) {
  return computeGrade(computeFinalScore(totalDeductions));
}
