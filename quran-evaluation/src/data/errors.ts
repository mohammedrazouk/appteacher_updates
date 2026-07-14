import type { ErrorDefinition } from '../types';

export const STAGES = [
  'رشيدي مرحلي',
  'رشيدي نهائي',
  'المرحلة التأهيلية',
  'المرحلة الأولى',
  'المرحلة الثانية',
  'المرحلة الثالثة',
  'المرحلة الرابعة + المرحلة الخامسة + كامل القرآن',
] as const;

export function getSection2Empty(stageIndex: number): boolean {
  return stageIndex < 2;
}

export function getSection2ShowTextOnly(stageIndex: number): boolean {
  return stageIndex === 2;
}

function buildSection2(stageIndex: number): ErrorDefinition[] {
  if (stageIndex < 3) return [];

  const base = [
    { id: 'mushaddad', name: 'المشدد الأغن', deduction: 0.5, onceOnly: false, section: 2 as const },
    { id: 'noon', name: 'أحكام النون', deduction: 0.5, onceOnly: false, section: 2 as const },
  ];

  if (stageIndex === 3) return base;

  const stage5Add = [
    { id: 'mem', name: 'أحكام الميم', deduction: 0.5, onceOnly: false, section: 2 as const },
    { id: 'idghamat', name: 'الإدغامات', deduction: 0.5, onceOnly: false, section: 2 as const },
    { id: 'lam-jalala', name: 'لام لفظ الجلالة', deduction: 0.5, onceOnly: false, section: 2 as const },
    { id: 'hamzat-wasl', name: 'همزة الوصل', deduction: 0.5, onceOnly: false, section: 2 as const },
    { id: 'raa', name: 'أحكام الراء', deduction: 0.5, onceOnly: false, section: 2 as const },
  ] satisfies ErrorDefinition[];

  if (stageIndex === 4) return [...base, ...stage5Add];

  const stage6Add = [
    { id: 'mad-asli', name: 'المد الأصلي', deduction: 0.5, onceOnly: false, section: 2 as const },
    { id: 'ahkam-mad', name: 'أحكام المد', deduction: 0.5, onceOnly: false, section: 2 as const },
  ] satisfies ErrorDefinition[];

  if (stageIndex === 5) return [...base, ...stage5Add, ...stage6Add];

  const stage7Add = [
    { id: 'qalqala', name: 'القلقلة', deduction: 0.5, onceOnly: false, section: 2 as const },
  ] satisfies ErrorDefinition[];

  return [...base, ...stage5Add, ...stage6Add, ...stage7Add];
}

function buildSection3(stageIndex: number): ErrorDefinition[] {
  const makeErr = (id: string, name: string, onceOnly = false): ErrorDefinition => ({
    id, name, deduction: 0.33, onceOnly, section: 3 as const,
  });

  if (stageIndex <= 1) {
    const rashidiBase = [
      makeErr('tafkhim-muraqqaq', 'تفخيم المرقق'),
      makeErr('tarqiq-mufakhim', 'ترقيق المفخم'),
      makeErr('adam-itmam-harakat', 'عدم إتمام الحركات'),
      makeErr('tamtit', 'التمطيط'),
      makeErr('tahjiya-taqti', 'تهجية وتقطيع الكلمة أثناء الدرج'),
      makeErr('huruf-lathawiya', 'الخطأ في الحروف اللثوية'),
      makeErr('tahwil-haraka-mad', 'تحويل الحركة لحرف مد'),
      makeErr('ibdal-harf', 'إبدال حرف بآخر'),
      makeErr('asma-alhuruf', 'الخطأ بأسماء الحروف أو الحركات'),
    ];

    if (stageIndex === 0) return rashidiBase;

    return [
      ...rashidiBase,
      makeErr('adam-tahqiq-mushaddad', 'عدم تحقيق الحرف المشدد'),
      makeErr('hathf-mad-tabiei', 'حذف المد الطبيعي'),
      makeErr('lam-shamsia-qamaria', 'الخطأ في اللام الشمسية أو القمرية'),
      makeErr('taraddud', 'التردد', true),
    ];
  }

  const tahiliaBase = [
    makeErr('hathf-mad-asli', 'حذف المد الأصلي'),
    makeErr('huruf-lathawiya-2', 'الحروف اللثوية'),
    makeErr('lam-shamsia-qamaria-2', 'اللام الشمسية والقمرية'),
    makeErr('tahwil-haraka-mad-2', 'تحويل الحركة لمد'),
    makeErr('adam-itmam-harakat-2', 'عدم إتمام الحركات'),
    makeErr('tafkhim-muraqqaq-2', 'تفخيم المرقق'),
    makeErr('tarqiq-mufakhim-2', 'ترقيق المفخم'),
    makeErr('adam-tahqiq-mushaddad-2', 'عدم تحقيق الحروف المشددة'),
    makeErr('ibdal-harf-2', 'إبدال حرف بآخر'),
  ];

  if (stageIndex === 2) return tahiliaBase;

  const oulaAdd = [
    makeErr('tamtit-2', 'تمطيط'),
    makeErr('taraddud-2', 'تردد', true),
    makeErr('adam-qalqala', 'عدم القلقلة'),
  ];

  if (stageIndex === 3) return [...tahiliaBase, ...oulaAdd];

  const thaniaAdd = [
    makeErr('hamza-ha-waqf', 'إضافة همزة أو هاء عند الوقف'),
    makeErr('adam-tabyin-harf', 'عدم تبيين الحرف الأخير'),
    makeErr('adam-tahqiq-hamza', 'عدم تحقيق الهمزة'),
    makeErr('qalqalat-sawakin', 'قلقلة السواكن'),
    makeErr('qiraa-nabr', 'القراءة بالنبر', true),
    makeErr('tatwil-ghunan', 'تطويل أو إنقاص أزمنة الغنن'),
  ];

  if (stageIndex === 4) return [...tahiliaBase, ...oulaAdd, ...thaniaAdd];

  const thalithaAdd = [
    makeErr('taqlil-imala', 'التقليل أو الإمالة', true),
    makeErr('khata-ikhfa', 'خطأ في أداء الإخفاء'),
    makeErr('khata-idgham', 'خطأ في أداء الإدغام'),
  ];

  if (stageIndex === 5) return [...tahiliaBase, ...oulaAdd, ...thaniaAdd, ...thalithaAdd];

  const rabiaAdd = [
    makeErr('qiraa-ghunna', 'قراءة مشوبة بغنة', true),
    makeErr('tatwil-mudud', 'تطويل أو إنقاص أزمنة المدود'),
    makeErr('itala-mad-asli', 'إطالة المد الأصلي'),
  ];

  return [
    ...tahiliaBase,
    ...oulaAdd.filter((e) => e.id !== 'adam-qalqala'),
    ...thaniaAdd,
    ...thalithaAdd,
    ...rabiaAdd,
  ];
}

export function getErrorsForStage(stageIndex: number): ErrorDefinition[] {
  const section1: ErrorDefinition[] = [
    { id: 'tanbih', name: 'تنبيه', deduction: 1, onceOnly: false, section: 1 },
    { id: 'khata', name: 'خطأ', deduction: 2, onceOnly: false, section: 1 },
  ];

  const section2 = buildSection2(stageIndex);
  const section3 = buildSection3(stageIndex);

  return [...section1, ...section2, ...section3];
}

export function getSections(stageIndex: number): { section: number; items: ErrorDefinition[] }[] {
  const all = getErrorsForStage(stageIndex);
  const section2ShowTextOnly = getSection2ShowTextOnly(stageIndex);
  const section2Empty = getSection2Empty(stageIndex);

  const result: { section: number; items: ErrorDefinition[] }[] = [
    { section: 1, items: all.filter((e) => e.section === 1) },
  ];

  if (!section2Empty) {
    result.push({ section: 2, items: section2ShowTextOnly ? [] : all.filter((e) => e.section === 2) });
  }

  result.push({ section: 3, items: all.filter((e) => e.section === 3) });

  return result;
}

export function getSectionTitle(section: number): string {
  switch (section) {
    case 1: return 'الخطأ الجلي';
    case 2: return 'الخطأ في أصل الحكم';
    case 3: return 'اللحن الخفي';
    default: return '';
  }
}
