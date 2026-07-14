import { useState } from 'react';
import { ClipboardList, User, BookOpen, Layers } from 'lucide-react';
import { STAGES } from '../data/errors';

interface Props {
  onStart: (name: string, page: number, stageIndex: number) => void;
  onOpenHistory: () => void;
}

export default function SetupForm({ onStart, onOpenHistory }: Props) {
  const [name, setName] = useState('');
  const [page, setPage] = useState('');
  const [stageIndex, setStageIndex] = useState<number>(0);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!name.trim()) errs.name = 'الرجاء إدخال اسم الطالب';
    if (!page.trim() || isNaN(Number(page)) || Number(page) < 1)
      errs.page = 'الرجاء إدخال رقم صفحة صحيح';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      onStart(name.trim(), Number(page), stageIndex);
    }
  };

  return (
    <div className="min-h-dvh bg-gradient-to-br from-emerald-50 to-slate-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="flex justify-between items-center mb-6">
          <div />
          <h1 className="text-2xl font-extrabold text-emerald-800 text-center">
            تقويم التلاوة
          </h1>
          <button
            type="button"
            onClick={onOpenHistory}
            className="p-2.5 rounded-xl bg-white shadow-sm border border-slate-200 text-slate-600 hover:text-emerald-700 hover:border-emerald-300 transition-colors cursor-pointer"
            title="سجل النتائج"
          >
            <ClipboardList size={22} />
          </button>
        </div>

        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 p-6">
          <form onSubmit={handleSubmit} className="space-y-5">
            <div>
              <label className="flex items-center gap-2 text-sm font-semibold text-slate-700 mb-1.5">
                <User size={16} className="text-emerald-600" />
                اسم الطالب
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => { setName(e.target.value); setErrors((prev) => ({ ...prev, name: '' })); }}
                placeholder="أدخل اسم الطالب"
                className={`w-full px-4 py-2.5 rounded-xl border ${
                  errors.name ? 'border-red-400 ring-2 ring-red-100' : 'border-slate-300'
                } text-sm focus:outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100 transition`}
              />
              {errors.name && <p className="text-red-500 text-xs mt-1 pr-1">{errors.name}</p>}
            </div>

            <div>
              <label className="flex items-center gap-2 text-sm font-semibold text-slate-700 mb-1.5">
                <BookOpen size={16} className="text-emerald-600" />
                رقم الصفحة
              </label>
              <input
                type="number"
                value={page}
                onChange={(e) => { setPage(e.target.value); setErrors((prev) => ({ ...prev, page: '' })); }}
                placeholder="أدخل رقم الصفحة"
                min="1"
                className={`w-full px-4 py-2.5 rounded-xl border ${
                  errors.page ? 'border-red-400 ring-2 ring-red-100' : 'border-slate-300'
                } text-sm focus:outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100 transition`}
              />
              {errors.page && <p className="text-red-500 text-xs mt-1 pr-1">{errors.page}</p>}
            </div>

            <div>
              <label className="flex items-center gap-2 text-sm font-semibold text-slate-700 mb-1.5">
                <Layers size={16} className="text-emerald-600" />
                المرحلة
              </label>
              <select
                value={stageIndex}
                onChange={(e) => setStageIndex(Number(e.target.value))}
                className="w-full px-4 py-2.5 rounded-xl border border-slate-300 text-sm bg-white focus:outline-none focus:border-emerald-400 focus:ring-2 focus:ring-emerald-100 transition"
              >
                {STAGES.map((stage, i) => (
                  <option key={i} value={i}>{stage}</option>
                ))}
              </select>
            </div>

            <button
              type="submit"
              className="w-full py-3 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-base shadow-sm transition-colors cursor-pointer"
            >
              بدء التقييم
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
