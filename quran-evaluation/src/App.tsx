import { useState, useCallback } from 'react';
import type { Screen, ErrorCounts, ErrorDefinition } from './types';
import { getErrorsForStage, STAGES } from './data/errors';
import { saveResult, generateId } from './utils/storage';
import { computeGrade } from './utils/grade';
import SetupForm from './components/SetupForm';
import EvaluationBoard from './components/EvaluationBoard';
import ResultSummary from './components/ResultSummary';
import HistoryView from './components/HistoryView';

export default function App() {
  const [screen, setScreen] = useState<Screen>('setup');
  const [studentName, setStudentName] = useState('');
  const [pageNumber, setPageNumber] = useState(0);
  const [stageIndex, setStageIndex] = useState(0);
  const [stageName, setStageName] = useState('');
  const [errorDefinitions, setErrorDefinitions] = useState<ErrorDefinition[]>([]);
  const [errorCounts, setErrorCounts] = useState<ErrorCounts>({});

  const handleStart = useCallback((name: string, page: number, stageIdx: number) => {
    setStudentName(name);
    setPageNumber(page);
    setStageIndex(stageIdx);
    setStageName(STAGES[stageIdx]);
    const errors = getErrorsForStage(stageIdx);
    setErrorDefinitions(errors);
    const initial: ErrorCounts = {};
    errors.forEach((e) => { initial[e.id] = 0; });
    setErrorCounts(initial);
    setScreen('evaluation');
  }, []);

  const handleIncrement = useCallback((errorId: string) => {
    setErrorCounts((prev) => ({ ...prev, [errorId]: (prev[errorId] || 0) + 1 }));
  }, []);

  const handleDecrement = useCallback((errorId: string) => {
    setErrorCounts((prev) => ({
      ...prev,
      [errorId]: Math.max(0, (prev[errorId] || 0) - 1),
    }));
  }, []);

  const handleSave = useCallback(() => {
    const totalDeductions = errorDefinitions.reduce(
      (sum, err) => sum + (errorCounts[err.id] || 0) * err.deduction,
      0
    );

    const activeErrors = errorDefinitions
      .filter((err) => (errorCounts[err.id] || 0) > 0)
      .map((err) => ({ name: err.name, count: errorCounts[err.id] }));

    saveResult({
      id: generateId(),
      studentName,
      pageNumber,
      stage: stageName,
      errors: activeErrors,
      totalDeductions,
      grade: computeGrade(stageIndex, totalDeductions),
      timestamp: Date.now(),
    });
  }, [errorDefinitions, errorCounts, studentName, pageNumber, stageName, stageIndex]);

  const handleNewEvaluation = useCallback(() => {
    setStudentName('');
    setPageNumber(0);
    setStageIndex(0);
    setStageName('');
    setErrorDefinitions([]);
    setErrorCounts({});
    setScreen('setup');
  }, []);

  const renderScreen = () => {
    switch (screen) {
      case 'setup':
        return (
          <SetupForm
            onStart={handleStart}
            onOpenHistory={() => setScreen('history')}
          />
        );
      case 'evaluation':
        return (
          <EvaluationBoard
            stageIndex={stageIndex}
            errorCounts={errorCounts}
            onIncrement={handleIncrement}
            onDecrement={handleDecrement}
            onShowResult={() => setScreen('result')}
            onBack={() => setScreen('setup')}
          />
        );
      case 'result':
        return (
          <ResultSummary
            studentName={studentName}
            pageNumber={pageNumber}
            stage={stageName}
            stageIndex={stageIndex}
            errorDefinitions={errorDefinitions}
            errorCounts={errorCounts}
            onSave={handleSave}
            onNewEvaluation={handleNewEvaluation}
            onBack={() => setScreen('evaluation')}
          />
        );
      case 'history':
        return <HistoryView onBack={() => setScreen('setup')} />;
    }
  };

  return <div className="font-cairo">{renderScreen()}</div>;
}
