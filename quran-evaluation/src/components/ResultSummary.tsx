import { useRef, useState } from 'react';
import { XCircle, Share2, RotateCcw, Save, ArrowLeft } from 'lucide-react';
import { computeGrade } from '../utils/grade';
import { shareAsImage, formatResultAsText, shareText } from '../utils/share';
import type { ErrorDefinition, ErrorCounts } from '../types';

interface Props {
  studentName: string;
  pageNumber: number;
  stage: string;
  stageIndex: number;
  errorDefinitions: ErrorDefinition[];
  errorCounts: ErrorCounts;
  onSave: () => void;
  onNewEvaluation: () => void;
  onBack: () => void;
}

const gradeColors: Record<string, string> = {
  تفوق: 'text-emerald-600 bg-emerald-100 border-emerald-300',
  ممتاز: 'text-blue-600 bg-blue-100 border-blue-300',
  'جيد جداً': 'text-amber-600 bg-amber-100 border-amber-300',
  جيد: 'text-orange-600 bg-orange-100 border-orange-300',
  إعادة: 'text-red-600 bg-red-100 border-red-300',
};

export default function ResultSummary({
  studentName,
  pageNumber,
  stage,
  stageIndex,
  errorDefinitions,
  errorCounts,
  onSave,
  onNewEvaluation,
  onBack,
}: Props) {
  const [saved, setSaved] = useState(false);
  const [sharing, setSharing] = useState(false);
  const resultRef = useRef<HTMLDivElement>(null);

  const totalDeductions = errorDefinitions.reduce(
    (sum, err) => sum + (errorCounts[err.id] || 0) * err.deduction,
    0
  );

  const grade = computeGrade(stageIndex, totalDeductions);

  const activeErrors = errorDefinitions
    .filter((err) => (errorCounts[err.id] || 0) > 0)
    .map((err) => ({ name: err.name, count: errorCounts[err.id] }));

  const handleSave = () => {
    onSave();
    setSaved(true);
  };

  const handleShare = async () => {
    if (!resultRef.current) return;
    setSharing(true);
    await shareAsImage(resultRef.current, `نتيجة-${studentName}`);
    setSharing(false);
  };

  const handleShareText = async () => {
    const text = formatResultAsText(studentName, stage, pageNumber, grade, activeErrors);
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
          <h2 className="text-xl font-bold text-emerald-800">النتيجة</h2>
        </div>

        <div
          ref={resultRef}
          className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6 space-y-5"
        >
          <div className="text-center">
            <h3 className="text-lg font-bold text-slate-800 mb-1">نتيجة تقييم التلاوة</h3>
            <p className="text-xs text-slate-500">بسم الله الرحمن الرحيم</p>
          </div>

          <div className="bg-slate-50 rounded-xl p-4 space-y-2.5 text-sm">
            <div className="flex justify-between">
              <span className="text-slate-500">الطالب</span>
              <span className="font-bold text-slate-800">{studentName}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">المرحلة</span>
              <span className="font-bold text-slate-800">{stage}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">رقم الصفحة</span>
              <span className="font-bold text-slate-800">{pageNumber}</span>
            </div>
            <div className="border-t border-slate-200 pt-2.5 flex justify-between items-center">
              <span className="text-slate-500">التقدير</span>
              <span className={`px-4 py-1 rounded-full border text-sm font-extrabold ${gradeColors[grade] || ''}`}>
                {grade}
              </span>
            </div>
          </div>

          {activeErrors.length > 0 && (
            <div>
              <h4 className="text-sm font-bold text-slate-700 mb-2">الأخطاء المسجلة</h4>
              <div className="space-y-1.5">
                {activeErrors.map((err, i) => (
                  <div key={i} className="flex justify-between items-center bg-slate-50 rounded-lg px-3.5 py-2 text-sm">
                    <span className="text-slate-700">{err.name}</span>
                    <span className="text-slate-500 text-xs">{err.count} مرات</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          <p className="text-center text-[10px] text-slate-400 pt-1">
            تقويم التلاوة - إتقان للتعليم والتنمية
          </p>
        </div>

        <div className="mt-5 flex flex-col gap-3">
          {!saved ? (
            <>
              <button
                type="button"
                onClick={handleSave}
                className="w-full py-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm shadow-sm transition-colors flex items-center justify-center gap-2 cursor-pointer"
              >
                <Save size={18} />
                حفظ النتيجة
              </button>
              <button
                type="button"
                onClick={onBack}
                className="w-full py-3 rounded-xl bg-white border-2 border-slate-300 text-slate-600 font-bold text-sm hover:bg-slate-50 transition-colors flex items-center justify-center gap-2 cursor-pointer"
              >
                <XCircle size={18} />
                إلغاء التقييم
              </button>
            </>
          ) : (
            <>
              <button
                type="button"
                onClick={handleShare}
                disabled={sharing}
                className="w-full py-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm shadow-sm transition-colors flex items-center justify-center gap-2 disabled:opacity-60 cursor-pointer"
              >
                <Share2 size={18} />
                {sharing ? 'جاري المشاركة...' : 'مشاركة النتيجة'}
              </button>
              <button
                type="button"
                onClick={handleShareText}
                className="w-full py-3 rounded-xl bg-white border-2 border-emerald-300 text-emerald-700 font-bold text-sm hover:bg-emerald-50 transition-colors flex items-center justify-center gap-2 cursor-pointer"
              >
                <Share2 size={18} />
                مشاركة كنص
              </button>
              <button
                type="button"
                onClick={onNewEvaluation}
                className="w-full py-3 rounded-xl bg-slate-700 hover:bg-slate-800 text-white font-bold text-sm shadow-sm transition-colors flex items-center justify-center gap-2 cursor-pointer"
              >
                <RotateCcw size={18} />
                تقييم جديد
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
