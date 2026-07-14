export interface ErrorDefinition {
  id: string;
  name: string;
  deduction: number;
  onceOnly: boolean;
  section: 1 | 2 | 3;
}

export interface EvaluationResult {
  id: string;
  studentName: string;
  pageNumber: number;
  stage: string;
  errors: { name: string; count: number }[];
  totalDeductions: number;
  grade: string;
  timestamp: number;
}

export type Screen = 'setup' | 'evaluation' | 'result' | 'history';

export interface StudentData {
  name: string;
  page: number;
  stage: string;
  stageIndex: number;
}

export interface ErrorCounts {
  [errorId: string]: number;
}
