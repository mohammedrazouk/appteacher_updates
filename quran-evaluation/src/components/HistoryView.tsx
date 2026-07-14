import { useState } from 'react';
import { Trash2, Share2, ClipboardList, ArrowLeft } from 'lucide-react';
import type { EvaluationResult as ResultType } from '../types';
import { loadResults, deleteResult, clearAllResults } from '../utils/storage';
import { shareText, formatAllResultsAsText } from '../utils/share';

interface Props {
  onBack: () => void;
}

const gradeColors: Record<string, string> = {
  تفوق: 'text-emerald-700 bg-emerald-100',
  ممتاز: 'text-blue-700 bg-blue-100',
  'جيد جداً': 'text-amber-700 bg-amber-100',
  جيد: 'text-orange-700 bg-orange-100',
  إعادة: 'text-red-700 bg-red-100',
};

export default function HistoryView({ onBack }: Props) {
  const [results, setResults] = useState<ResultType[]>(() => loadResults());


  const handleDelete = (id: string) => {
    deleteResult(id);
    setResults((prev) => prev.filter((r) => r.id !== id));
  };

  const handleClearAll = () => {
    if (window.confirm('هل أنت متأكد من حذف جميع النتائج؟')) {
      clearAllResults();
      setResults([]);
    }
  };

  const handleShareAll = async () => {
    const text = formatAllResultsAsText(
      results.map((r) => ({
        studentName: r.studentName,
        stage: r.stage,
        pageNumber: r.pageNumber,
        grade: r.grade,
        timestamp: r.timestamp,
      }))
    );
    await shareText(text);
  };

  const handleShareSingle = async (result: ResultType) => {
    const errorsText = result.errors.length > 0
      ? result.errors.map((e) => `  - ${e.name}: ${e.count} مرات`).join('\n')
      : '  لا توجد أخطاء';

    const text = [
      `📖 نتيجة تقييم تلاوة القرآن`,
      `━━━━━━━━━━━━━━`,
      `الطالب: ${result.studentName}`,
      `المرحلة: ${result.stage}`,
      `رقم الصفحة: ${result.pageNumber}`,
      `التقدير: ${result.grade}`,
      `━━━━━━━━━━━━━━`,
      errorsText,
      `━━━━━━━━━━━━━━`,
      new Date(result.timestamp).toLocaleDateString('ar-SA'),
    ].join('\n');

    await shareText(text);
  };

  return (
    <div className="min-h-dvh bg-gradient-to-br from-emerald-50 to-slate-100">
      <div className="max-w-lg mx-auto px-4 py-6">
        <div className="flex items-center gap-3 mb-6">
          <button
            type="button"
            onClick={onBack}
            className="p-2 rounded-xl bg-white shadow-sm border border-slate-200 text-slate-600 hover:text-emerald-700 transition-colors cursor-pointer"
          >
            <ArrowLeft size={22} />
          </button>
          <h2 className="text-xl font-bold text-emerald-800">سجل النتائج</h2>
          {results.length > 0 && (
            <span className="text-xs text-slate-500 bg-white px-2.5 py-1 rounded-full border border-slate-200">
              {results.length}
            </span>
          )}
        </div>

        {results.length === 0 ? (
          <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-10 text-center">
            <ClipboardList size={48} className="mx-auto text-slate-300 mb-3" />
            <p className="text-slate-500 font-medium">لا توجد نتائج محفوظة</p>
            <p className="text-slate-400 text-xs mt-1">قم بتقييم طالب أولاً</p>
          </div>
        ) : (
          <>
            <div className="flex gap-2 mb-4">
              <button
                type="button"
                onClick={handleShareAll}
                className="flex-1 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-bold shadow-sm transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <Share2 size={16} />
                مشاركة الجميع
              </button>
              <button
                type="button"
                onClick={handleClearAll}
                className="py-2.5 px-4 rounded-xl bg-red-50 hover:bg-red-100 text-red-600 text-sm font-bold border border-red-200 transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <Trash2 size={16} />
                حذف الكل
              </button>
            </div>

            <div className="space-y-3">
              {results.map((result) => (
                <div
                  key={result.id}
                  className="bg-white rounded-2xl shadow-sm border border-slate-200 p-4"
                >
                  <div className="flex items-start justify-between mb-2">
                    <div>
                      <h4 className="font-bold text-slate-800">{result.studentName}</h4>
                      <p className="text-xs text-slate-500 mt-0.5">
                        {result.stage} | صفحة {result.pageNumber}
                      </p>
                    </div>
                    <span
                      className={`text-xs font-extrabold px-3 py-1 rounded-full ${gradeColors[result.grade] || 'text-slate-700 bg-slate-100'}`}
                    >
                      {result.grade}
                    </span>
                  </div>

                  {result.errors.length > 0 && (
                    <div className="bg-slate-50 rounded-lg p-2.5 mb-2">
                      {result.errors.map((err, i) => (
                        <div key={i} className="flex justify-between text-xs text-slate-600 py-0.5">
                          <span>{err.name}</span>
                          <span className="text-slate-400">{err.count} مرات</span>
                        </div>
                      ))}
                    </div>
                  )}

                  <div className="flex justify-between items-center">
                    <span className="text-[10px] text-slate-400">
                      {new Date(result.timestamp).toLocaleDateString('ar-SA')}
                    </span>
                    <div className="flex gap-1.5">
                      <button
                        type="button"
                        onClick={() => handleShareSingle(result)}
                        className="p-1.5 rounded-lg bg-emerald-50 hover:bg-emerald-100 text-emerald-600 transition-colors cursor-pointer"
                        title="مشاركة"
                      >
                        <Share2 size={14} />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDelete(result.id)}
                        className="p-1.5 rounded-lg bg-red-50 hover:bg-red-100 text-red-500 transition-colors cursor-pointer"
                        title="حذف"
                      >
                        <Trash2 size={14} />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
