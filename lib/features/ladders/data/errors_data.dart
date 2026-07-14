import 'package:flutter/material.dart';
import '../models/ladder_result.dart';

const List<String> stages = [
  'رشيدي مرحلي',
  'رشيدي نهائي',
  'المرحلة التأهيلية (1+2)',
  '3+4',
  'المرحلة الأولى (1-6)',
  '7+8',
  '9+10',
  'المرحلة الثانية (7-12)',
  '13+14',
  '15+16',
  'المرحلة الثالثة (13-18)',
  '19+20',
  '21+22',
  'المرحلة الرابعة (19-24)',
  '25+26',
  '27+28',
  'المرحلة الخامسة (25-30)',
  'كامل القرآن',
];

bool isRashidiGroup(int stageIndex) => stageIndex <= 1;
bool isTahiliaOnePlusTwo(int stageIndex) => stageIndex == 2;
bool isPhaseOne(int stageIndex) => stageIndex == 3 || stageIndex == 4;
bool isStage5(int stageIndex) => stageIndex == 5; // 7+8
bool isStage6(int stageIndex) => stageIndex == 6; // 9+10
bool isStage7(int stageIndex) => stageIndex == 7; // المرحلة الثانية (7-12)
bool isStage8(int stageIndex) => stageIndex == 8; // 13+14
bool isStage9(int stageIndex) => stageIndex == 9; // 15+16
bool isStage10(int stageIndex) => stageIndex == 10; // المرحلة الثالثة (13-18)
bool isStage11(int stageIndex) => stageIndex == 11; // 19+20
bool isStage12(int stageIndex) => stageIndex == 12; // 21+22
bool isStage13(int stageIndex) => stageIndex == 13; // المرحلة الرابعة (19-24)
bool isStage14(int stageIndex) => stageIndex == 14; // 25+26
bool isStage15(int stageIndex) => stageIndex == 15; // 27+28
bool isStage16(int stageIndex) => stageIndex == 16; // المرحلة الخامسة (25-30)
bool isStage17(int stageIndex) => stageIndex == 17; // كامل القرآن
bool isPhaseOnePlus(int stageIndex) => stageIndex >= 5;
bool isPhaseFourPlus(int stageIndex) => stageIndex >= 11;

bool section2Empty(int stageIndex) => false;
bool section2ShowTextOnly(int stageIndex) => isTahiliaOnePlusTwo(stageIndex);
bool section2HasButtons(int stageIndex) =>
    isPhaseOne(stageIndex) || isPhaseOnePlus(stageIndex);

List<ErrorButton> _aslAlHukmForStage(int stageIndex) {
  final base = <ErrorButton>[
    const ErrorButton(
        id: 'p1_ah_mushaddad',
        name: 'المشدد الأغن',
        deduction: 1,
        section: 2,
        colorGroup: 2),
    const ErrorButton(
        id: 'p1_ah_noon',
        name: 'أحكام النون',
        deduction: 1,
        section: 2,
        colorGroup: 2),
  ];
  if (stageIndex >= 5) {
    base.add(const ErrorButton(
        id: 'p2_ah_mem_sakina',
        name: 'الميم الساكنة',
        deduction: 1,
        section: 2,
        colorGroup: 2));
  }
  if (stageIndex >= 6) {
    base.add(const ErrorButton(
        id: 'p2_ah_idghamat',
        name: 'الإدغامات',
        deduction: 1,
        section: 2,
        colorGroup: 2));
    base.add(const ErrorButton(
        id: 'p2_ah_lam_jalala',
        name: 'لام لفظ الجلالة',
        deduction: 1,
        section: 2,
        colorGroup: 2));
  }
  if (stageIndex >= 7) {
    base.add(const ErrorButton(
        id: 'p2_ah_hamzat_wasl',
        name: 'همزة الوصل',
        deduction: 1,
        section: 2,
        colorGroup: 2));
    base.add(const ErrorButton(
        id: 'p2_ah_raa',
        name: 'أحكام الراء',
        deduction: 1,
        section: 2,
        colorGroup: 2));
  }
  if (stageIndex >= 9) {
    base.add(const ErrorButton(
        id: 'p3_ah_ahkam_mad',
        name: 'أحكام المد',
        deduction: 1,
        section: 2,
        colorGroup: 2));
  }
  if (isPhaseFourPlus(stageIndex)) {
    base.add(const ErrorButton(
        id: 'p4_ah_qalqala',
        name: 'القلقلة',
        deduction: 1,
        section: 2,
        colorGroup: 2));
  }
  return base;
}

List<ErrorButton> getErrorsForStage(int stageIndex) {
  if (stageIndex == 0) {
    return [
      ..._rashidiSection1(),
      ..._rashidiMurahhaliObservations(),
    ];
  }
  if (stageIndex == 1) {
    return [
      ..._rashidiSection1(),
      ..._rashidiNihaiObservations(),
    ];
  }
  if (isTahiliaOnePlusTwo(stageIndex)) {
    return [
      ..._section1(),
      ..._tahiliaLahnKhafi(),
    ];
  }
  if (isPhaseOne(stageIndex) || isPhaseOnePlus(stageIndex)) {
    return [
      ..._section1(),
      ..._aslAlHukmForStage(stageIndex),
      ..._phaseOneOrTwoLahnKhafi(stageIndex),
    ];
  }
  return [..._section1()];
}

List<ErrorButton> _section1() => const [
      ErrorButton(id: 'tanbih', name: 'تنبيه', deduction: 3, section: 1),
      ErrorButton(id: 'khata', name: 'خطأ', deduction: 5, section: 1),
    ];

List<ErrorButton> _rashidiSection1() => const [
      ErrorButton(id: 'tanbih', name: 'تنبيه', deduction: 2, section: 1),
      ErrorButton(id: 'khata', name: 'خطأ', deduction: 4, section: 1),
    ];

List<ErrorButton> _rashidiMurahhaliObservations() {
  return [
    ErrorButton(
        id: 'rm_obs1_1',
        name: 'تفخيم المرقق',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rm_obs1_2',
        name: 'ترقيق المفخم',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rm_obs1_3',
        name: 'عدم إتمام الحركات',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rm_obs1_4',
        name: 'التمطيط',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rm_obs1_5',
        name: 'تهجية وتقطيع الكلمة أثناء الدرج',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rm_obs2_1',
        name: 'الخطأ في الحروف اللثوية',
        deduction: 2,
        section: 2,
        colorGroup: 2),
    ErrorButton(
        id: 'rm_obs2_2',
        name: 'تحويل الحركة لحرف مد',
        deduction: 2,
        section: 2,
        colorGroup: 2),
    ErrorButton(
        id: 'rm_obs3_1',
        name: 'إبدال حرف بآخر',
        deduction: 2,
        section: 2,
        colorGroup: 3,
        onceOnly: true),
    ErrorButton(
        id: 'rm_obs3_2',
        name: 'أسماء الحروف أو الحركات',
        deduction: 2,
        section: 2,
        colorGroup: 3,
        onceOnly: true),
  ];
}

List<ErrorButton> _rashidiNihaiObservations() {
  return [
    ErrorButton(
        id: 'rn_obs1_1',
        name: 'تفخيم المرقق',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rn_obs1_2',
        name: 'ترقيق المفخم',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rn_obs1_3',
        name: 'عدم إتمام الحركات',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rn_obs1_4',
        name: 'التمطيط',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rn_obs1_5',
        name: 'تهجية وتقطيع الكلمة أثناء الدرج',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rn_obs1_6',
        name: 'عدم تحقيق الحرف المشدد',
        deduction: 0.5,
        section: 2,
        colorGroup: 1),
    ErrorButton(
        id: 'rn_obs2_1',
        name: 'الخطأ في الحروف اللثوية',
        deduction: 2,
        section: 2,
        colorGroup: 2),
    ErrorButton(
        id: 'rn_obs2_2',
        name: 'تحويل الحركة لحرف مد',
        deduction: 2,
        section: 2,
        colorGroup: 2),
    ErrorButton(
        id: 'rn_obs2_3',
        name: 'حذف المد الطبيعي',
        deduction: 2,
        section: 2,
        colorGroup: 2),
    ErrorButton(
        id: 'rn_obs2_4',
        name: 'الخطأ في اللام الشمسية أو القمرية',
        deduction: 2,
        section: 2,
        colorGroup: 2),
    ErrorButton(
        id: 'rn_obs3_1',
        name: 'إبدال حرف بآخر',
        deduction: 2,
        section: 2,
        colorGroup: 3,
        onceOnly: true),
    ErrorButton(
        id: 'rn_obs3_2',
        name: 'أسماء الحروف أو الحركات',
        deduction: 2,
        section: 2,
        colorGroup: 3,
        onceOnly: true),
    ErrorButton(
        id: 'rn_obs3_3',
        name: 'التردد',
        deduction: 2,
        section: 2,
        colorGroup: 3,
        onceOnly: true),
  ];
}

List<ErrorButton> _tahiliaLahnKhafi() {
  return [
    ErrorButton(
        id: 'tah_obs1_1',
        name: 'حذف المد الأصلي',
        deduction: 1,
        section: 3,
        colorGroup: 1),
    ErrorButton(
        id: 'tah_obs1_2',
        name: 'الحروف اللثوية',
        deduction: 1,
        section: 3,
        colorGroup: 1),
    ErrorButton(
        id: 'tah_obs1_3',
        name: 'اللام الشمسية والقمرية',
        deduction: 1,
        section: 3,
        colorGroup: 1),
    ErrorButton(
        id: 'tah_obs1_4',
        name: 'تحويل الحركة لمد',
        deduction: 1,
        section: 3,
        colorGroup: 1),
    ErrorButton(
        id: 'tah_obs2_1',
        name: 'عدم إتمام الحركات',
        deduction: 1,
        section: 3,
        colorGroup: 2,
        onceOnly: true),
    ErrorButton(
        id: 'tah_obs2_2',
        name: 'تفخيم المرقق',
        deduction: 1,
        section: 3,
        colorGroup: 2,
        onceOnly: true),
    ErrorButton(
        id: 'tah_obs2_3',
        name: 'ترقيق المفخم',
        deduction: 1,
        section: 3,
        colorGroup: 2,
        onceOnly: true),
    ErrorButton(
        id: 'tah_obs2_4',
        name: 'عدم تحقيق الحروف المشددة',
        deduction: 1,
        section: 3,
        colorGroup: 2,
        onceOnly: true),
    ErrorButton(
        id: 'tah_obs2_5',
        name: 'إبدال حرف بآخر',
        deduction: 1,
        section: 3,
        colorGroup: 2,
        onceOnly: true),
  ];
}

List<ErrorButton> _phaseOneOrTwoLahnKhafi(int stageIndex) {
  final isPhaseThreeFour = isPhaseOne(stageIndex); // 3+4 و 1-6
  if (isPhaseThreeFour) {
    return [
      ErrorButton(
          id: 'p34_obs1_1',
          name: 'حذف المد الأصلي',
          deduction: 2,
          section: 3,
          colorGroup: 1),
      ErrorButton(
          id: 'p34_obs1_2',
          name: 'الحروف اللثوية',
          deduction: 2,
          section: 3,
          colorGroup: 1),
      ErrorButton(
          id: 'p34_obs1_3',
          name: 'اللام الشمسية والقمرية',
          deduction: 2,
          section: 3,
          colorGroup: 1),
      ErrorButton(
          id: 'p34_obs1_4',
          name: 'تحويل الحركة لمد',
          deduction: 2,
          section: 3,
          colorGroup: 1),
      ErrorButton(
          id: 'p34_obs2_1',
          name: 'تفخيم المرقق',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p34_obs2_2',
          name: 'ترقيق المفخم',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p34_obs2_3',
          name: 'تمطيط',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p34_obs2_4',
          name: 'تردد',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p34_obs3_1',
          name: 'عدم إتمام الحركات',
          deduction: 1,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p34_obs3_2',
          name: 'عدم تحقيق الحروف المشددة',
          deduction: 1,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p34_obs3_3',
          name: 'إبدال حرف بآخر',
          deduction: 1,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p34_obs3_4',
          name: 'عدم القلقلة',
          deduction: 1,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
    ];
  }

  final isPhaseFourPlus = stageIndex >= 11;
  if (isPhaseFourPlus) {
    return [
      ErrorButton(
          id: 'p4_obs1_1',
          name: 'حذف المد الأصلي',
          deduction: 2,
          section: 3,
          colorGroup: 1),
      ErrorButton(
          id: 'p4_obs1_2',
          name: 'الحروف اللثوية',
          deduction: 2,
          section: 3,
          colorGroup: 1),
      ErrorButton(
          id: 'p4_obs1_3',
          name: 'اللام الشمسية والقمرية',
          deduction: 2,
          section: 3,
          colorGroup: 1),
      ErrorButton(
          id: 'p4_obs1_4',
          name: 'تحويل الحركة لمد',
          deduction: 2,
          section: 3,
          colorGroup: 1),
      ErrorButton(
          id: 'p4_obs2_1',
          name: 'تمطيط',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p4_obs2_2',
          name: 'تردد',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p4_obs2_3',
          name: 'تفخيم المرقق',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p4_obs2_4',
          name: 'ترقيق المفخم',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p4_obs2_5',
          name: 'عدم تحقيق المشدد',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p4_obs2_6',
          name: 'عدم إتمام الحركات',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p4_obs2_7',
          name: 'عدم تحقيق الهمزة',
          deduction: 0.5,
          section: 3,
          colorGroup: 2),
      ErrorButton(
          id: 'p4_obs3_1',
          name: 'إبدال حرف بآخر',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs3_2',
          name: 'قلقلة السواكن',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs3_3',
          name: 'القراءة بالنبر',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs3_4',
          name: 'تطويل أو إنقاص أزمنة الغنن',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs3_5',
          name: 'إضافة همزة أو هاء عند الوقف',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs3_6',
          name: 'قراءة مشوبة بغنة',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs3_7',
          name: 'تطويل أو إنقاص أزمنة المدود',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs4_1',
          name: 'عدم تبيين الحرف الأخير',
          deduction: 1,
          section: 3,
          colorGroup: 4,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs4_2',
          name: 'التقليل أو الإمالة',
          deduction: 1,
          section: 3,
          colorGroup: 4,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs4_3',
          name: 'خطأ في أداء الإخفاء',
          deduction: 1,
          section: 3,
          colorGroup: 4,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs4_4',
          name: 'خطأ في أداء الإدغام',
          deduction: 1,
          section: 3,
          colorGroup: 4,
          onceOnly: true),
      ErrorButton(
          id: 'p4_obs4_5',
          name: 'إطالة المد الأصلي',
          deduction: 1,
          section: 3,
          colorGroup: 4,
          onceOnly: true),
    ];
  }

  final hasObs4 = stageIndex >= 5; // 7+8 وما بعدها
  final hasExtendedObs3 = stageIndex >= 8; // 13+14 وما بعدها
  final hasNewObs4Items = stageIndex >= 8; // 13+14 وما بعدها
  return [
    ErrorButton(
        id: 'p_obs1_1',
        name: 'حذف المد الأصلي',
        deduction: 2,
        section: 3,
        colorGroup: 1),
    ErrorButton(
        id: 'p_obs1_2',
        name: 'الحروف اللثوية',
        deduction: 2,
        section: 3,
        colorGroup: 1),
    ErrorButton(
        id: 'p_obs1_3',
        name: 'اللام الشمسية والقمرية',
        deduction: 2,
        section: 3,
        colorGroup: 1),
    ErrorButton(
        id: 'p_obs1_4',
        name: 'تحويل الحركة لمد',
        deduction: 2,
        section: 3,
        colorGroup: 1),
    ErrorButton(
        id: 'p_obs2_1',
        name: 'تفخيم المرقق',
        deduction: 0.5,
        section: 3,
        colorGroup: 2),
    ErrorButton(
        id: 'p_obs2_2',
        name: 'ترقيق المفخم',
        deduction: 0.5,
        section: 3,
        colorGroup: 2),
    ErrorButton(
        id: 'p_obs2_3',
        name: 'تمطيط',
        deduction: 0.5,
        section: 3,
        colorGroup: 2),
    ErrorButton(
        id: 'p_obs2_4',
        name: 'تردد',
        deduction: 0.5,
        section: 3,
        colorGroup: 2),
    ErrorButton(
        id: 'p_obs3_1',
        name: 'إبدال حرف بآخر',
        deduction: 2,
        section: 3,
        colorGroup: 3,
        onceOnly: true),
    ErrorButton(
        id: 'p_obs3_2',
        name: 'عدم القلقلة',
        deduction: 2,
        section: 3,
        colorGroup: 3,
        onceOnly: true),
    ErrorButton(
        id: 'p_obs3_3',
        name: 'عدم تحقيق المشدد',
        deduction: 2,
        section: 3,
        colorGroup: 3,
        onceOnly: true),
    ErrorButton(
        id: 'p_obs3_4',
        name: 'عدم إتمام الحركات',
        deduction: 2,
        section: 3,
        colorGroup: 3,
        onceOnly: true),
    if (hasExtendedObs3) ...[
      ErrorButton(
          id: 'p_obs3_5',
          name: 'قلقلة السواكن',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p_obs3_6',
          name: 'القراءة بالنبر',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
      ErrorButton(
          id: 'p_obs3_7',
          name: 'تطويل أو إنقاص أزمنة الغنن',
          deduction: 2,
          section: 3,
          colorGroup: 3,
          onceOnly: true),
    ],
    if (hasObs4) ...[
      ErrorButton(
          id: 'p_obs4_1',
          name: 'إضافة همزة أو هاء عند الوقف',
          deduction: 1,
          section: 3,
          colorGroup: 4,
          onceOnly: true),
      ErrorButton(
          id: 'p_obs4_2',
          name: 'عدم تبيين الحرف الأخير',
          deduction: 1,
          section: 3,
          colorGroup: 4,
          onceOnly: true),
      ErrorButton(
          id: 'p_obs4_3',
          name: 'عدم تحقيق الهمزة',
          deduction: 1,
          section: 3,
          colorGroup: 4,
          onceOnly: true),
      if (stageIndex < 8) ...[
        ErrorButton(
            id: 'p_obs4_4',
            name: 'قلقلة السواكن',
            deduction: 1,
            section: 3,
            colorGroup: 4,
            onceOnly: true),
        ErrorButton(
            id: 'p_obs4_5',
            name: 'القراءة بالنبر',
            deduction: 1,
            section: 3,
            colorGroup: 4,
            onceOnly: true),
        ErrorButton(
            id: 'p_obs4_6',
            name: 'تطويل أو إنقاص أزمنة الغنن',
            deduction: 1,
            section: 3,
            colorGroup: 4,
            onceOnly: true),
      ],
      if (hasNewObs4Items) ...[
        ErrorButton(
            id: 'p_obs4_7',
            name: 'التقليل أو الإمالة',
            deduction: 1,
            section: 3,
            colorGroup: 4,
            onceOnly: true),
        ErrorButton(
            id: 'p_obs4_8',
            name: 'خطأ في أداء الإخفاء',
            deduction: 1,
            section: 3,
            colorGroup: 4,
            onceOnly: true),
        ErrorButton(
            id: 'p_obs4_9',
            name: 'خطأ في أداء الإدغام',
            deduction: 1,
            section: 3,
            colorGroup: 4,
            onceOnly: true),
      ],
    ],
  ];
}

String sectionTitle(int section, {int stageIndex = -1}) {
  if (section == 2) {
    if (stageIndex >= 0 && !isRashidiGroup(stageIndex)) {
      return 'الخطأ بأصل الحكم';
    }
    return 'الملاحظات التحسينية';
  }
  switch (section) {
    case 1:
      return 'اللحن الجلي';
    case 3:
      return 'اللحن الخفي';
    default:
      return '';
  }
}

Color sectionBg(int section) {
  switch (section) {
    case 1:
      return const Color(0xFFFFF1F2);
    case 2:
      return const Color(0xFFEFF6FF);
    case 3:
      return const Color(0xFFEFF6FF);
    default:
      return Colors.grey.shade50;
  }
}

Color sectionBorder(int section) {
  switch (section) {
    case 1:
      return const Color(0xFFFECDD3);
    case 2:
      return const Color(0xFFBFDBFE);
    case 3:
      return const Color(0xFFBFDBFE);
    default:
      return Colors.grey.shade200;
  }
}

Color sectionBtnBg(int section, {int buttonIndex = 0, int colorGroup = 0}) {
  switch (section) {
    case 1:
      return const Color(0xFFFFF1F2);
    case 2:
      if (colorGroup == 1) return const Color(0xFFFEF2F2);
      if (colorGroup == 2) return const Color(0xFFEFF6FF);
      if (colorGroup == 3) return const Color(0xFFECFDF5);
      if (colorGroup == 4) return const Color(0xFFFAF5FF);
      if (buttonIndex == 0) return const Color(0xFFFEF2F2);
      if (buttonIndex == 1) return const Color(0xFFEFF6FF);
      return const Color(0xFFECFDF5);
    case 3:
      if (colorGroup == 1) return const Color(0xFFFEF2F2);
      if (colorGroup == 2) return const Color(0xFFEFF6FF);
      if (colorGroup == 3) return const Color(0xFFFAF5FF);
      if (colorGroup == 4) return const Color(0xFFECFDF5);
      if (buttonIndex == 0) return const Color(0xFFFEF2F2);
      if (buttonIndex == 1) return const Color(0xFFEFF6FF);
      if (buttonIndex == 2) return const Color(0xFFFAF5FF);
      return const Color(0xFFECFDF5);
    default:
      return Colors.grey.shade100;
  }
}

Color sectionBtnText(int section, {int buttonIndex = 0, int colorGroup = 0}) {
  switch (section) {
    case 1:
      return const Color(0xFFBE123C);
    case 2:
      if (colorGroup == 1) return const Color(0xFFBE123C);
      if (colorGroup == 2) return const Color(0xFF1D4ED8);
      if (colorGroup == 3) return const Color(0xFF065F46);
      if (colorGroup == 4) return const Color(0xFF6B21A8);
      if (buttonIndex == 0) return const Color(0xFFBE123C);
      if (buttonIndex == 1) return const Color(0xFF1D4ED8);
      return const Color(0xFF065F46);
    case 3:
      if (colorGroup == 1) return const Color(0xFFBE123C);
      if (colorGroup == 2) return const Color(0xFF1D4ED8);
      if (colorGroup == 3) return const Color(0xFF6B21A8);
      if (colorGroup == 4) return const Color(0xFF065F46);
      if (buttonIndex == 0) return const Color(0xFFBE123C);
      if (buttonIndex == 1) return const Color(0xFF1D4ED8);
      if (buttonIndex == 2) return const Color(0xFF6B21A8);
      return const Color(0xFF065F46);
    default:
      return Colors.grey.shade800;
  }
}

Color sectionBtnBorder(int section, {int buttonIndex = 0, int colorGroup = 0}) {
  switch (section) {
    case 1:
      return const Color(0xFFFECDD3);
    case 2:
      if (colorGroup == 1) return const Color(0xFFFECACA);
      if (colorGroup == 2) return const Color(0xFFBFDBFE);
      if (colorGroup == 3) return const Color(0xFFA7F3D0);
      if (colorGroup == 4) return const Color(0xFFE9D5FF);
      if (buttonIndex == 0) return const Color(0xFFFECACA);
      if (buttonIndex == 1) return const Color(0xFFBFDBFE);
      return const Color(0xFFA7F3D0);
    case 3:
      if (colorGroup == 1) return const Color(0xFFFECACA);
      if (colorGroup == 2) return const Color(0xFFBFDBFE);
      if (colorGroup == 3) return const Color(0xFFE9D5FF);
      if (colorGroup == 4) return const Color(0xFFA7F3D0);
      if (buttonIndex == 0) return const Color(0xFFFECACA);
      if (buttonIndex == 1) return const Color(0xFFBFDBFE);
      if (buttonIndex == 2) return const Color(0xFFE9D5FF);
      return const Color(0xFFA7F3D0);
    default:
      return Colors.grey.shade300;
  }
}

Color sectionHeaderText(int section) {
  switch (section) {
    case 1:
      return const Color(0xFFBE123C);
    case 2:
      return const Color(0xFF1D4ED8);
    case 3:
      return const Color(0xFF1D4ED8);
    default:
      return Colors.grey.shade800;
  }
}
