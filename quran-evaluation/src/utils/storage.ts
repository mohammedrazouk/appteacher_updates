import type { EvaluationResult } from '../types';

const STORAGE_KEY = 'quran-evaluation-results';

export function loadResults(): EvaluationResult[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    return JSON.parse(raw) as EvaluationResult[];
  } catch {
    return [];
  }
}

export function saveResult(result: EvaluationResult): void {
  const results = loadResults();
  results.push(result);
  localStorage.setItem(STORAGE_KEY, JSON.stringify(results));
}

export function deleteResult(id: string): void {
  const results = loadResults().filter((r) => r.id !== id);
  localStorage.setItem(STORAGE_KEY, JSON.stringify(results));
}

export function clearAllResults(): void {
  localStorage.removeItem(STORAGE_KEY);
}

export function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
}
