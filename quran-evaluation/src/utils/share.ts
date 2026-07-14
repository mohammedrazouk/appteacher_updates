export async function shareAsImage(element: HTMLElement, fileName: string): Promise<void> {
  try {
    const html2canvas = (await import('html2canvas')).default;
    const canvas = await html2canvas(element, {
      backgroundColor: '#ffffff',
      scale: 2,
      useCORS: true,
    });

    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, 'image/png')
    );

    if (!blob) return;

    if (navigator.share) {
      const file = new File([blob], `${fileName}.png`, { type: 'image/png' });
      await navigator.share({
        files: [file],
        title: fileName,
      });
    } else {
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${fileName}.png`;
      a.click();
      URL.revokeObjectURL(url);
    }
  } catch {
    // fallback silently
  }
}

export async function shareText(text: string): Promise<void> {
  if (navigator.share) {
    try {
      await navigator.share({ text });
      return;
    } catch {
      // fallback to clipboard
    }
  }

  try {
    await navigator.clipboard.writeText(text);
  } catch {
    // silently fail
  }
}

export function formatResultAsText(
  studentName: string,
  stage: string,
  pageNumber: number,
  grade: string,
  errors: { name: string; count: number }[]
): string {
  const lines = [
    `📖 تقييم تلاوة القرآن`,
    `━━━━━━━━━━━━━━━━━━`,
    `الطالب: ${studentName}`,
    `المرحلة: ${stage}`,
    `رقم الصفحة: ${pageNumber}`,
    `التقدير: ${grade}`,
  ];

  if (errors.length > 0) {
    lines.push(`━━━━━━━━━━━━━━━━━━`);
    errors.forEach((e) => {
      lines.push(`${e.name}: ${e.count} مرات`);
    });
  }

  return lines.join('\n');
}

export function formatAllResultsAsText(
  results: { studentName: string; stage: string; pageNumber: number; grade: string; timestamp: number }[]
): string {
  const lines = ['📊 سجل نتائج تقييم التلاوة', `━━━━━━━━━━━━━━━━━━`];

  results.forEach((r, i) => {
    const date = new Date(r.timestamp).toLocaleDateString('ar-SA');
    lines.push(
      `${i + 1}. ${r.studentName} | ${r.stage} | صفحة ${r.pageNumber} | ${r.grade} | ${date}`
    );
  });

  return lines.join('\n');
}
