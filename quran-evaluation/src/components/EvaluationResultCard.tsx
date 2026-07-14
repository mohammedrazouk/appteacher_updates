import { User, BookOpen, Layers, AlertTriangle, BadgeCheck } from 'lucide-react';

interface ErrorItem {
  name: string;
  count: number;
}

interface EvaluationResultCardProps {
  studentName: string;
  pageNumber: number;
  stage: string;
  errors: ErrorItem[];
  grade: string;
}

const gradeColors: Record<string, string> = {
  تفوق: 'text-emerald-700',
  ممتاز: 'text-blue-700',
  'جيد جداً': 'text-amber-600',
  جيد: 'text-orange-600',
  إعادة: 'text-red-600',
};

export default function EvaluationResultCard({
  studentName,
  pageNumber,
  stage,
  errors,
  grade,
}: EvaluationResultCardProps) {
  return (
    <div dir="rtl" className="w-full max-w-md mx-auto">
      <div className="bg-white rounded-2xl shadow-md border border-slate-100 overflow-hidden">
        {/* Header */}
        <div className="text-center pt-6 pb-4 px-6">
          <h2 className="text-lg font-bold text-emerald-800">نتيجة تقييم التلاوة</h2>
          <p className="text-sm text-slate-500 mt-1">تطبيق التقييم القرآني الرسمي</p>
        </div>

        {/* Student Details */}
        <div className="mx-6 mb-4 bg-emerald-50 border border-emerald-100 rounded-xl p-4 space-y-3">
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-2 text-emerald-800 text-sm">
              <User size={16} />
              <span>الطالب</span>
            </div>
            <span className="font-bold text-slate-800 text-sm">{studentName}</span>
          </div>
          <div className="border-b border-emerald-100/50" />
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-2 text-emerald-800 text-sm">
              <BookOpen size={16} />
              <span>الصفحة</span>
            </div>
            <span className="font-bold text-slate-800 text-sm">{pageNumber}</span>
          </div>
          <div className="border-b border-emerald-100/50" />
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-2 text-emerald-800 text-sm">
              <Layers size={16} />
              <span>المرحلة</span>
            </div>
            <span className="font-bold text-slate-800 text-sm">{stage}</span>
          </div>
        </div>

        {/* Errors Summary */}
        <div className="px-6 pb-4">
          <div className="flex items-center gap-2 mb-3">
            <AlertTriangle size={18} className="text-amber-500" />
            <h3 className="text-sm font-bold text-slate-700">ملخص الملاحظات</h3>
          </div>

          {errors.length > 0 ? (
            <div className="space-y-2">
              {errors.map((err, i) => (
                <div
                  key={i}
                  className="flex justify-between items-center bg-slate-50 rounded-lg px-3.5 py-2.5 text-sm"
                >
                  <span className="text-slate-700">{err.name}</span>
                  <span className="bg-white border border-slate-200 px-3 py-0.5 rounded-full shadow-sm text-xs text-slate-600 font-medium">
                    {err.count}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <div className="bg-slate-50 rounded-lg py-6 text-center">
              <BadgeCheck size={32} className="mx-auto text-emerald-400 mb-2" />
              <p className="text-slate-500 text-sm">لا توجد ملاحظات، تلاوة متقنة!</p>
            </div>
          )}
        </div>

        {/* Final Grade */}
        <div className="border-t border-slate-100 px-6 py-5 text-center">
          <p className="text-xs text-slate-500 mb-1">التقدير النهائي</p>
          <p className={`text-3xl font-extrabold ${gradeColors[grade] || 'text-slate-700'}`}>
            {grade}
          </p>
        </div>
      </div>
    </div>
  );
}
