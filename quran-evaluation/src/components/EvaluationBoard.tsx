import { getSections, getSectionTitle, getSection2ShowTextOnly, getSection2Empty } from '../data/errors';
import type { ErrorCounts } from '../types';

interface Props {
  stageIndex: number;
  errorCounts: ErrorCounts;
  onIncrement: (errorId: string) => void;
  onDecrement: (errorId: string) => void;
  onShowResult: () => void;
  onBack: () => void;
}

const sectionConfig: Record<
  number,
  {
    number: string;
    badgeBg: string;
    badgeText: string;
    btnBg: string;
    btnBgActive: string;
    btnBorder: string;
    btnText: string;
    hoverBg: string;
    grid: string;
  }
> = {
  1: {
    number: '1',
    badgeBg: 'bg-rose-100',
    badgeText: 'text-rose-600',
    btnBg: 'bg-rose-50',
    btnBgActive: 'bg-rose-100',
    btnBorder: 'border-rose-200',
    btnText: 'text-rose-700',
    hoverBg: 'hover:bg-rose-100',
    grid: 'grid-cols-2',
  },
  2: {
    number: '2',
    badgeBg: 'bg-amber-100',
    badgeText: 'text-amber-600',
    btnBg: 'bg-amber-50',
    btnBgActive: 'bg-amber-100',
    btnBorder: 'border-amber-200',
    btnText: 'text-amber-700',
    hoverBg: 'hover:bg-amber-100',
    grid: 'grid-cols-2 md:grid-cols-3',
  },
  3: {
    number: '3',
    badgeBg: 'bg-blue-100',
    badgeText: 'text-blue-600',
    btnBg: 'bg-blue-50',
    btnBgActive: 'bg-blue-100',
    btnBorder: 'border-blue-200',
    btnText: 'text-blue-700',
    hoverBg: 'hover:bg-blue-100',
    grid: 'grid-cols-2 md:grid-cols-3',
  },
};

export default function EvaluationBoard({ stageIndex, errorCounts, onIncrement, onDecrement, onShowResult, onBack }: Props) {
  const sections = getSections(stageIndex);
  const hasErrors = Object.values(errorCounts).some((c) => c > 0);
  const section2TextOnly = getSection2ShowTextOnly(stageIndex);
  const section2Empty = getSection2Empty(stageIndex);

  return (
    <div dir="rtl" className="min-h-dvh bg-white font-sans">
      <div className="max-w-2xl mx-auto px-4 py-8">
        {/* Top Bar */}
        <div className="flex items-center gap-3 mb-10">
          <button
            type="button"
            onClick={onBack}
            className="w-9 h-9 rounded-lg bg-slate-50 border border-slate-200 text-slate-600 hover:text-emerald-700 hover:border-emerald-300 transition-colors cursor-pointer flex items-center justify-center"
            aria-label="رجوع"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M18 15l-6-6-6 6" />
            </svg>
          </button>
          <h2 className="text-2xl font-bold text-slate-800">لوحة التقييم</h2>
        </div>

        <div className="space-y-8">
          {sections.map(({ section, items }) => {
            const cfg = sectionConfig[section];
            const showTextOnly = section2TextOnly && section === 2;

            return (
              <div key={section}>
                {/* Section Header */}
                <div className="flex items-center gap-2.5 mb-4">
                  <div
                    className={`w-7 h-7 rounded-md flex items-center justify-center text-sm font-bold ${cfg.badgeBg} ${cfg.badgeText}`}
                  >
                    {cfg.number}
                  </div>
                  <h3 className="text-lg font-bold text-slate-800">
                    {getSectionTitle(section)}
                  </h3>
                </div>

                {/* Section Content */}
                {showTextOnly ? (
                  <p className="text-amber-700 text-sm font-medium text-center py-4 bg-amber-50 border border-amber-200 rounded-lg">
                    المطالبة بالنطق السليم
                  </p>
                ) : items.length === 0 && !section2Empty ? (
                  <p className="text-slate-400 text-sm text-center py-4">لا توجد أخطاء في هذا القسم</p>
                ) : items.length === 0 ? null : (
                  <div className={`grid ${cfg.grid} gap-3`}>
                    {items.map((err) => {
                      const count = errorCounts[err.id] || 0;
                      const isDisabled = err.onceOnly && count >= 1;
                      const isActive = count > 0;

                      return (
                        <button
                          key={err.id}
                          type="button"
                          onClick={() => onIncrement(err.id)}
                          disabled={isDisabled}
                          onContextMenu={(e) => { e.preventDefault(); if (count > 0) onDecrement(err.id); }}
                          className={`
                            py-4 px-3 rounded-lg border font-bold text-sm text-center
                            transition-colors
                            ${isActive ? cfg.btnBgActive : cfg.btnBg}
                            ${cfg.btnBorder} ${cfg.btnText}
                            ${cfg.hoverBg}
                            ${isDisabled
                              ? 'opacity-50 cursor-not-allowed'
                              : 'cursor-pointer'
                            }
                          `}
                        >
                          {err.name}
                          {count > 0 && (
                            <span className="ms-1.5 text-xs opacity-70 font-normal">×{count}</span>
                          )}
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Bottom Actions */}
        <div className="mt-12 flex gap-3">
          <button
            type="button"
            onClick={onBack}
            className="flex-1 py-3 rounded-lg bg-white border border-slate-300 text-slate-600 font-bold text-sm hover:bg-slate-50 transition-colors cursor-pointer"
          >
            رجوع
          </button>
          <button
            type="button"
            onClick={onShowResult}
            disabled={!hasErrors}
            className={`flex-[2] py-3 rounded-lg border font-bold text-sm transition-colors ${
              hasErrors
                ? 'bg-emerald-600 hover:bg-emerald-700 border-emerald-600 text-white cursor-pointer'
                : 'bg-slate-100 border-slate-100 text-slate-400 cursor-not-allowed'
            }`}
          >
            عرض النتيجة
          </button>
        </div>
      </div>
    </div>
  );
}
