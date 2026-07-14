class ExamStep {
  final String name;
  final double duration;

  const ExamStep({required this.name, required this.duration});
}

class ExamSequence {
  ExamSequence._();

  static const double passingGrade = 79.0;

  static const List<ExamStep> steps = [
    ExamStep(name: 'رشيدي مرحلي', duration: 90),
    ExamStep(name: 'رشيدي نهائي', duration: 90),
    ExamStep(name: '1', duration: 105),
    ExamStep(name: '1+2', duration: 60),
    ExamStep(name: '3+4', duration: 105),
    ExamStep(name: '1+6', duration: 67.5),
    ExamStep(name: '7+8', duration: 60),
    ExamStep(name: '9+10', duration: 60),
    ExamStep(name: '7+12', duration: 45),
    ExamStep(name: '13+14', duration: 45),
    ExamStep(name: '15+16', duration: 45),
    ExamStep(name: '13+18', duration: 45),
    ExamStep(name: '19+20', duration: 45),
    ExamStep(name: '21+22', duration: 45),
    ExamStep(name: '19+24', duration: 45),
    ExamStep(name: '25+26', duration: 37.5),
    ExamStep(name: '27+28', duration: 37.5),
    ExamStep(name: '25+30', duration: 37.5),
    ExamStep(name: 'كامل القرآن', duration: 30),
  ];

  static int get lastIndex => steps.length - 1;

  static ExamStep stepAt(int index) {
    if (index < 0 || index >= steps.length) {
      return steps.last;
    }
    return steps[index];
  }

  static String nameAt(int index) => stepAt(index).name;

  static double durationAt(int index) => stepAt(index).duration;

  static bool isFinished(int index) => index >= steps.length;

  static bool isQuranCompleted(int index) => index >= steps.length;
}
