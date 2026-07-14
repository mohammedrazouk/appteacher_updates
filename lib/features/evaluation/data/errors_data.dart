import 'package:flutter/material.dart';
import '../models/evaluation_result.dart';

const List<String> stages = [
  'رشيدي مرحلي',
  'رشيدي نهائي',
  'المرحلة التأهيلية',
  'المرحلة الأولى',
  'المرحلة الثانية',
  'المرحلة الثالثة',
  'المرحلة (4 + 5 ) + كامل القرآن',
];

bool section2Empty(int stageIndex) => stageIndex < 2;
bool section2ShowTextOnly(int stageIndex) => stageIndex == 2;

const double _third = 1 / 3;

bool isThirdDeduction(double deduction) =>
    (deduction - _third).abs() < 0.001;

double deductionForButton(int count, double perPress) {
  if (count <= 0) return 0;
  if (isThirdDeduction(perPress)) {
    return count / 3.0;
  }
  return count * perPress;
}

double totalDeductionForButtons(
    List<ErrorButton> errors, Map<String, int> counts) {
  double total = 0;
  for (final e in errors) {
    total += deductionForButton(counts[e.id] ?? 0, e.deduction);
  }
  return total;
}

String formatDeductionValue(double value) {
  if (value == 0) return '0';
  if (isThirdDeduction(value) || true) {
    final thirds = (value * 3).round();
    if ((value * 3 - thirds).abs() < 0.001) {
      final whole = thirds ~/ 3;
      final rem = thirds % 3;
      if (rem == 0) return '$whole';
      if (whole == 0) return rem == 1 ? '0.33' : '0.67';
      return rem == 1 ? '$whole.33' : '$whole.67';
    }
  }
  if (value == value.truncateToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

List<ErrorButton> getErrorsForStage(int stageIndex) {
  return [
    ..._section1(),
    ..._section2(stageIndex),
    ..._section3(stageIndex),
  ];
}

List<ErrorButton> _section1() => const [
      ErrorButton(id: 'tanbih', name: 'تنبيه', deduction: 1, section: 1),
      ErrorButton(id: 'khata', name: 'خطأ', deduction: 2, section: 1),
    ];

List<ErrorButton> _section2(int si) {
  if (si < 3) return [];

  const base = [
    ErrorButton(
        id: 'mushaddad', name: 'المشدد الأغن', deduction: 0.5, section: 2),
    ErrorButton(id: 'noon', name: 'أحكام النون', deduction: 0.5, section: 2),
  ];

  if (si == 3) return [...base];

  const add5 = [
    ErrorButton(id: 'mem', name: 'أحكام الميم', deduction: 0.5, section: 2),
    ErrorButton(id: 'idghamat', name: 'الإدغامات', deduction: 0.5, section: 2),
    ErrorButton(
        id: 'lam-jalala', name: 'لام لفظ الجلالة', deduction: 0.5, section: 2),
    ErrorButton(
        id: 'hamzat-wasl', name: 'همزة الوصل', deduction: 0.5, section: 2),
    ErrorButton(id: 'raa', name: 'أحكام الراء', deduction: 0.5, section: 2),
  ];

  if (si == 4) return [...base, ...add5];

  const add6 = [
    ErrorButton(
        id: 'mad-asli', name: 'المد الأصلي', deduction: 0.5, section: 2),
    ErrorButton(
        id: 'ahkam-mad', name: 'أحكام المد', deduction: 0.5, section: 2),
  ];

  if (si == 5) return [...base, ...add5, ...add6];

  const add7 = [
    ErrorButton(id: 'qalqala', name: 'القلقلة', deduction: 0.5, section: 2),
  ];

  return [...base, ...add5, ...add6, ...add7];
}

List<ErrorButton> _section3(int si) {
  if (si <= 1) {
    const rashidiBase = [
      ErrorButton(
          id: 'tafkhim-muraqqaq',
          name: 'تفخيم المرقق',
          deduction: 1 / 3,
          section: 3),
      ErrorButton(
          id: 'tarqiq-mufakhim',
          name: 'ترقيق المفخم',
          deduction: 1 / 3,
          section: 3),
      ErrorButton(
          id: 'adam-itmam-harakat',
          name: 'عدم إتمام الحركات',
          deduction: 1 / 3,
          section: 3),
      ErrorButton(id: 'tamtit', name: 'التمطيط', deduction: 1 / 3, section: 3),
      ErrorButton(
          id: 'tahjiya-taqti',
          name: 'تهجية وتقطيع أثناء الدرج',
          deduction: 1 / 3,
          section: 3),
      ErrorButton(
          id: 'huruf-lathawiya',
          name: 'الخطأ في الحروف اللثوية',
          deduction: 1 / 3,
          section: 3),
      ErrorButton(
          id: 'tahwil-haraka-mad',
          name: 'تحويل الحركة لحرف مد',
          deduction: 1 / 3,
          section: 3),
      ErrorButton(
          id: 'ibdal-harf',
          name: 'إبدال حرف بآخر',
          deduction: 1 / 3,
          section: 3),
      ErrorButton(
          id: 'asma-alhuruf',
          name: 'أسماء الحروف أو الحركات',
          deduction: 1 / 3,
          section: 3),
    ];
    if (si == 0) return [...rashidiBase];
    return [
      ...rashidiBase,
      const ErrorButton(
          id: 'adam-tahqiq-mushaddad',
          name: 'عدم تحقيق الحرف المشدد',
          deduction: 1 / 3,
          section: 3),
      const ErrorButton(
          id: 'hathf-mad-tabiei',
          name: 'حذف المد الطبيعي',
          deduction: 1 / 3,
          section: 3),
      const ErrorButton(
          id: 'lam-shamsia-qamaria',
          name: 'اللام الشمسية أو القمرية',
          deduction: 1 / 3,
          section: 3),
      ErrorButton(
          id: 'taraddud',
          name: 'التردد',
          deduction: 1 / 3,
          onceOnly: true,
          section: 3),
    ];
  }

  const tahiliaBase = [
    ErrorButton(
        id: 'hathf-mad-asli',
        name: 'حذف المد الأصلي',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'huruf-lathawiya-2',
        name: 'الحروف اللثوية',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'lam-shamsia-qamaria-2',
        name: 'اللام الشمسية والقمرية',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'tahwil-haraka-mad-2',
        name: 'تحويل الحركة لمد',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'adam-itmam-harakat-2',
        name: 'عدم إتمام الحركات',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'tafkhim-muraqqaq-2',
        name: 'تفخيم المرقق',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'tarqiq-mufakhim-2',
        name: 'ترقيق المفخم',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'adam-tahqiq-mushaddad-2',
        name: 'عدم تحقيق الحروف المشددة',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'ibdal-harf-2',
        name: 'إبدال حرف بآخر',
        deduction: 1 / 3,
        section: 3),
  ];

  if (si == 2) return [...tahiliaBase];

  const oulaAdd = [
    ErrorButton(id: 'tamtit-2', name: 'تمطيط', deduction: 1 / 3, section: 3),
    ErrorButton(
        id: 'taraddud-2',
        name: 'تردد',
        deduction: 1 / 3,
        onceOnly: true,
        section: 3),
    ErrorButton(
        id: 'adam-qalqala', name: 'عدم القلقلة', deduction: 1 / 3, section: 3),
  ];

  if (si == 3) return [...tahiliaBase, ...oulaAdd];

  const thaniaAdd = [
    ErrorButton(
        id: 'hamza-ha-waqf',
        name: 'إضافة ء أو هـ عند الوقف',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'adam-tabyin-harf',
        name: 'عدم تبيين الحرف الأخير',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'adam-tahqiq-hamza',
        name: 'عدم تحقيق الهمزة',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'qalqalat-sawakin',
        name: 'قلقلة السواكن',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'qiraa-nabr',
        name: 'القراءة بالنبر',
        deduction: 1 / 3,
        onceOnly: true,
        section: 3),
    ErrorButton(
        id: 'tatwil-ghunan',
        name: 'تطويل أو إنقاص أزمنة الغنن',
        deduction: 1 / 3,
        section: 3),
  ];

  if (si == 4) return [...tahiliaBase, ...oulaAdd, ...thaniaAdd];

  const thalithaAdd = [
    ErrorButton(
        id: 'taqlil-imala',
        name: 'التقليل أو الإمالة',
        deduction: 1 / 3,
        onceOnly: true,
        section: 3),
    ErrorButton(
        id: 'khata-ikhfa',
        name: 'خطأ في أداء الإخفاء',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'khata-idgham',
        name: 'خطأ في أداء الإدغام',
        deduction: 1 / 3,
        section: 3),
  ];

  if (si == 5)
    return [...tahiliaBase, ...oulaAdd, ...thaniaAdd, ...thalithaAdd];

  const rabiaAdd = [
    ErrorButton(
        id: 'qiraa-ghunna',
        name: 'قراءة مشوبة بغنة',
        deduction: 1 / 3,
        onceOnly: true,
        section: 3),
    ErrorButton(
        id: 'tatwil-mudud',
        name: 'تطويل أو إنقاص أزمنة المدود',
        deduction: 1 / 3,
        section: 3),
    ErrorButton(
        id: 'itala-mad-asli',
        name: 'إطالة المد الأصلي',
        deduction: 1 / 3,
        section: 3),
  ];

  return [
    ...tahiliaBase,
    ...oulaAdd.where((e) => e.id != 'adam-qalqala'),
    ...thaniaAdd,
    ...thalithaAdd,
    ...rabiaAdd,
  ];
}

String sectionTitle(int section) {
  switch (section) {
    case 1:
      return 'اللحن الجلي';
    case 2:
      return 'الخطأ في أصل الحكم';
    case 3:
      return 'اللحن الخفي';
    default:
      return '';
  }
}

Color sectionBg(int section) {
  switch (section) {
    case 1:
      return const Color(0xFFFFF1F2); // rose 50
    case 2:
      return Colors.amber.shade50;
    case 3:
      return Colors.blue.shade50;
    default:
      return Colors.grey.shade50;
  }
}

Color sectionBorder(int section) {
  switch (section) {
    case 1:
      return const Color(0xFFFECDD3); // rose 200
    case 2:
      return Colors.amber.shade200;
    case 3:
      return Colors.blue.shade200;
    default:
      return Colors.grey.shade200;
  }
}

Color sectionBtnBg(int section) {
  switch (section) {
    case 1:
      return const Color(0xFFFFE4E6); // rose 100
    case 2:
      return Colors.amber.shade100;
    case 3:
      return Colors.blue.shade100;
    default:
      return Colors.grey.shade100;
  }
}

Color sectionBtnText(int section) {
  switch (section) {
    case 1:
      return const Color(0xFF9F1239); // rose 800
    case 2:
      return Colors.amber.shade800;
    case 3:
      return Colors.blue.shade800;
    default:
      return Colors.grey.shade800;
  }
}

Color sectionBadge(int section) {
  switch (section) {
    case 1:
      return const Color(0xFFF43F5E); // rose 500
    case 2:
      return Colors.amber.shade500;
    case 3:
      return Colors.blue.shade500;
    default:
      return Colors.grey.shade500;
  }
}

Color sectionHeaderText(int section) {
  switch (section) {
    case 1:
      return const Color(0xFF9F1239); // rose 800
    case 2:
      return Colors.amber.shade800;
    case 3:
      return Colors.blue.shade800;
    default:
      return Colors.grey.shade800;
  }
}
