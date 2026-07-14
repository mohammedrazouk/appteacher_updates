String computeGrade(int stageIndex, double totalDeductions) {
  final isRashidi = stageIndex <= 1;

  if (totalDeductions == 0) return 'تفوق';

  if (isRashidi) {
    if (totalDeductions <= 2) return 'ممتاز';
    if (totalDeductions <= 4) return 'جيد جداً';
    if (totalDeductions <= 6) return 'جيد';
    return 'إعادة';
  }

  if (totalDeductions <= 1) return 'ممتاز';
  if (totalDeductions <= 2) return 'جيد جداً';
  if (totalDeductions <= 3) return 'جيد';
  return 'إعادة';
}
