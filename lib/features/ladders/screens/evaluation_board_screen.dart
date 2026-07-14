import 'package:flutter/material.dart';
import '../data/errors_data.dart';
import '../data/grade_calculator.dart';
import '../data/storage_helper.dart';
import '../models/ladder_result.dart';
import 'result_screen.dart';

class EvaluationBoardScreen extends StatefulWidget {
  final String studentName;
  final int stageIndex;
  final double tajweedTheoryDeduction;
  final double tajweedTheoryScore;

  const EvaluationBoardScreen({
    super.key,
    required this.studentName,
    required this.stageIndex,
    this.tajweedTheoryDeduction = 0,
    this.tajweedTheoryScore = 10,
  });

  @override
  State<EvaluationBoardScreen> createState() => _EvaluationBoardScreenState();
}

class _EvaluationBoardScreenState extends State<EvaluationBoardScreen> {
  late final List<ErrorButton> _errors;
  final Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _errors = getErrorsForStage(widget.stageIndex);
    for (final e in _errors) {
      _counts[e.id] = 0;
    }
  }

  void _increment(String id) {
    setState(() => _counts[id] = (_counts[id] ?? 0) + 1);
  }

  void _decrement(String id) {
    setState(() => _counts[id] = ((_counts[id] ?? 0) - 1).clamp(0, 999999));
  }

  List<MapEntry<int, List<ErrorButton>>> get _sections {
    final map = <int, List<ErrorButton>>{};
    for (final e in _errors) {
      map.putIfAbsent(e.section, () => []).add(e);
    }
    final entries = map.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final s2Empty = section2Empty(widget.stageIndex);
    final s2TextOnly = section2ShowTextOnly(widget.stageIndex);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('سلم الاختبار',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final entry in _sections)
              if (!(entry.key == 2 && s2Empty))
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: _buildSectionWidget(entry.key, entry.value),
                ),
            if (s2TextOnly && !_sections.any((e) => e.key == 2))
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _buildSectionWidget(2, const []),
              ),
            const SizedBox(height: 8),
            _LiveResultCard(
              errorButtons: _errors,
              counts: _counts,
              stageIndex: widget.stageIndex,
              studentName: widget.studentName,
              tajweedTheoryDeduction: widget.tajweedTheoryDeduction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWidget(int section, List<ErrorButton> items) {
    final s2TextOnly = section2ShowTextOnly(widget.stageIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _sectionBadgeBg(section),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$section',
                  style: TextStyle(
                    color: _sectionBadgeText(section),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                sectionTitle(section, stageIndex: widget.stageIndex),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        if (section == 2 && s2TextOnly)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              border: Border.all(color: const Color(0xFFFDE68A)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'المطالبة بالنطق السليم',
                style: TextStyle(
                  color: Color(0xFFB45309),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'لا توجد أخطاء في هذا القسم',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          _buildSectionGrid(section, items),
      ],
    );
  }

  Widget _buildSectionGrid(int section, List<ErrorButton> items) {
    final crossAxisCount =
        section == 1 ? 2 : (items.length <= 3 ? items.length : 3);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: section == 1 ? 1.5 : 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final err = items[index];
        final count = _counts[err.id] ?? 0;
        final isDisabled = err.onceOnly && count >= 1;
        return _ErrorTile(
          err: err,
          count: count,
          isDisabled: isDisabled,
          section: section,
          buttonIndex: index,
          onIncrement: () => _increment(err.id),
          onDecrement: () => _decrement(err.id),
        );
      },
    );
  }

  Color _sectionBadgeBg(int section) {
    switch (section) {
      case 1:
        return const Color(0xFFFFE4E6);
      case 2:
        return const Color(0xFFDBEAFE);
      case 3:
        return const Color(0xFFDBEAFE);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _sectionBadgeText(int section) {
    switch (section) {
      case 1:
        return const Color(0xFFE11D48);
      case 2:
        return const Color(0xFF2563EB);
      case 3:
        return const Color(0xFF2563EB);
      default:
        return Colors.grey.shade600;
    }
  }
}

class _ErrorTile extends StatelessWidget {
  final ErrorButton err;
  final int count;
  final bool isDisabled;
  final int section;
  final int buttonIndex;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ErrorTile({
    required this.err,
    required this.count,
    required this.isDisabled,
    required this.section,
    required this.buttonIndex,
    required this.onIncrement,
    required this.onDecrement,
  });

  Color get _bg {
    if (isDisabled) return const Color(0xFFF1F5F9);
    return sectionBtnBg(section,
        buttonIndex: buttonIndex, colorGroup: err.colorGroup);
  }

  Color get _border {
    if (isDisabled) return const Color(0xFFE2E8F0);
    return sectionBtnBorder(section,
        buttonIndex: buttonIndex, colorGroup: err.colorGroup);
  }

  Color get _text {
    if (isDisabled) return const Color(0xFF94A3B8);
    return sectionBtnText(section,
        buttonIndex: buttonIndex, colorGroup: err.colorGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isDisabled ? null : onIncrement,
        onLongPress: count > 0 ? onDecrement : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  err.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _text,
                  ),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(height: 10),
                _LaddersCounterRow(
                  count: count,
                  deduction: err.deduction,
                  isDisabled: isDisabled,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                  borderColor: _border,
                  textColor: _text,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LaddersCounterRow extends StatelessWidget {
  final int count;
  final double deduction;
  final bool isDisabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color borderColor;
  final Color textColor;

  const _LaddersCounterRow({
    required this.count,
    required this.deduction,
    required this.isDisabled,
    required this.onIncrement,
    required this.onDecrement,
    required this.borderColor,
    required this.textColor,
  });

  String _formatDeduction() {
    final total = count * deduction;
    if (total == total.truncateToDouble()) {
      return total.toStringAsFixed(0);
    }
    return total.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LaddersCounterButton(
            icon: Icons.remove,
            color: const Color(0xFFEF4444),
            onTap: count > 0 ? onDecrement : null,
          ),
          Container(
            width: 1,
            height: 20,
            color: borderColor,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            child: Text(
              _formatDeduction(),
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: borderColor,
          ),
          _LaddersCounterButton(
            icon: Icons.add,
            color: const Color(0xFF10B981),
            onTap: isDisabled ? null : onIncrement,
          ),
        ],
      ),
    );
  }
}

class _LaddersCounterButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _LaddersCounterButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? color.withValues(alpha: 0.3) : color,
        ),
      ),
    );
  }
}

class _LiveResultCard extends StatefulWidget {
  final List<ErrorButton> errorButtons;
  final Map<String, int> counts;
  final int stageIndex;
  final String studentName;
  final double tajweedTheoryDeduction;

  const _LiveResultCard({
    required this.errorButtons,
    required this.counts,
    required this.stageIndex,
    required this.studentName,
    this.tajweedTheoryDeduction = 0,
  });

  @override
  State<_LiveResultCard> createState() => _LiveResultCardState();
}

class _LiveResultCardState extends State<_LiveResultCard> {
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF065F46)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final quranDeductions = widget.errorButtons.fold<double>(
      0,
      (sum, e) => sum + (widget.counts[e.id] ?? 0) * e.deduction,
    );
    final totalDeductions = quranDeductions + widget.tajweedTheoryDeduction;
    final grade = computeGradeFromDeductions(totalDeductions);

    final activeErrors = widget.errorButtons
        .where((e) => (widget.counts[e.id] ?? 0) > 0)
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          const Text(
            'نتيجة الاختبار',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'عرض نتيجة الاختبار والملاحظات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFA7F3D0).withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                _infoRow(Icons.person_outline, 'الطالب', widget.studentName),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0xFFA7F3D0).withValues(alpha: 0.5),
                ),
                _infoRow(Icons.layers_outlined, 'الاختبار',
                    stages[widget.stageIndex]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9)),
                bottom: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 20, color: Colors.amber.shade500),
                    const SizedBox(width: 8),
                    Text(
                      'ملخص الملاحظات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (activeErrors.isEmpty && widget.tajweedTheoryDeduction <= 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'لا توجد ملاحظات، تلاوة متقنة!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  )
                else ...[
                  if (widget.tajweedTheoryDeduction > 0)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.menu_book,
                                    size: 16, color: Color(0xFFB45309)),
                                const SizedBox(width: 6),
                                Text('التجويد النظري',
                                    style: TextStyle(
                                        color: const Color(0xFFB45309),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.tajweedTheoryDeduction ==
                                      widget.tajweedTheoryDeduction
                                          .truncateToDouble()
                                  ? '-${widget.tajweedTheoryDeduction.toInt()}'
                                  : '-${widget.tajweedTheoryDeduction.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...activeErrors.map(
                    (e) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(e.name,
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 13)),
                          ),
                          Text(
                            '×${widget.counts[e.id] ?? 0}',
                            style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${(e.deduction * (widget.counts[e.id] ?? 0)).toStringAsFixed(e.deduction.truncateToDouble() == e.deduction ? 0 : 1)}',
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate_outlined,
                                size: 18, color: Color(0xFFB91C1C)),
                            SizedBox(width: 6),
                            Text(
                              'مجموع العلامات المخصومة',
                              style: TextStyle(
                                color: Color(0xFFB91C1C),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          totalDeductions == totalDeductions.truncateToDouble()
                              ? '-${totalDeductions.toInt()}'
                              : '-${totalDeductions.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'العلامة النهائية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Builder(builder: (context) {
            final score = computeFinalScore(totalDeductions);
            final scoreColor =
                score < 79 ? const Color(0xFFDC2626) : const Color(0xFF065F46);
            return Column(
              children: [
                Text(
                  '${score.toStringAsFixed(1)} / 100',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: scoreColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'التقدير: $grade',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final quranDeductions = widget.errorButtons.fold<double>(
                  0,
                  (sum, e) => sum + (widget.counts[e.id] ?? 0) * e.deduction,
                );
                final totalDeductions =
                    quranDeductions + widget.tajweedTheoryDeduction;
                final activeErrors = widget.errorButtons
                    .where((e) => (widget.counts[e.id] ?? 0) > 0)
                    .map((e) =>
                        ErrorEntry(name: e.name, count: widget.counts[e.id]!))
                    .toList();
                if (widget.tajweedTheoryDeduction > 0) {
                  activeErrors.insert(
                      0, ErrorEntry(name: 'التجويد النظري', count: 1));
                }
                final grade = computeGradeFromDeductions(totalDeductions);
                await LadderStorage.saveResult(
                  LadderResult(
                    id: generateId(),
                    studentName: widget.studentName,
                    stage: stages[widget.stageIndex],
                    errors: activeErrors,
                    totalDeductions: totalDeductions,
                    grade: grade,
                    timestamp: DateTime.now(),
                  ),
                );
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(
                      studentName: widget.studentName,
                      stageIndex: widget.stageIndex,
                      errorButtons: widget.errorButtons,
                      counts: Map.from(widget.counts),
                      tajweedTheoryDeduction: widget.tajweedTheoryDeduction,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ النتيجة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CA390),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
