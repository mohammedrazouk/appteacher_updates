import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/errors_data.dart';
import '../../../core/constants/app_colors.dart';
import '../data/storage_helper.dart';
import '../data/grade_calculator.dart';
import '../models/evaluation_result.dart';
import 'history_view_screen.dart';

class SetupFormScreen extends StatefulWidget {
  const SetupFormScreen({super.key});

  @override
  State<SetupFormScreen> createState() => _SetupFormScreenState();
}

class _SetupFormScreenState extends State<SetupFormScreen> {
  final _nameController = TextEditingController();
  final _pageController = TextEditingController();
  int _stageIndex = 0;
  String? _nameError;
  String? _pageError;
  int _resultsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final results = await EvaluationStorage.loadResults();
    if (mounted) setState(() => _resultsCount = results.length);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startEvaluation() {
    setState(() {
      _nameError = null;
      _pageError = null;
    });

    final name = _nameController.text.trim();
    final pageText = _pageController.text.trim();
    bool valid = true;

    if (name.isEmpty) {
      _nameError = 'الرجاء إدخال اسم الطالب';
      valid = false;
    }
    final page = int.tryParse(pageText);
    if (pageText.isEmpty || page == null || page < 1) {
      _pageError = 'الرجاء إدخال رقم صفحة صحيح';
      valid = false;
    }
    if (!valid) {
      setState(() {});
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluationBoardScreen(
          studentName: name,
          pageNumber: page!,
          stageIndex: _stageIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        'تقييم الصفحة',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandBlue,
                        ),
                      ),
                      const Spacer(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            elevation: 0,
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HistoryViewScreen(),
                                  ),
                                );
                                _loadCount();
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFBB8601)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.history,
                                        size: 25, color: Color(0xFFBB8601)),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'سجل التقييمات',
                                      style: TextStyle(
                                        color: Color(0xFFBB8601),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_resultsCount > 0)
                            Positioned(
                              top: -6,
                              right: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.brandTeal,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                                child: Text(
                                  '$_resultsCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(text: 'اسم الطالب'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'أدخل اسم الطالب',
                            hintTextDirection: TextDirection.rtl,
                            errorText: _nameError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel(text: 'رقم الصفحة'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _pageController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'أدخل رقم الصفحة',
                            hintTextDirection: TextDirection.rtl,
                            errorText: _pageError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel(text: 'المرحلة'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: _stageIndex,
                          items: List.generate(
                            stages.length,
                            (i) => DropdownMenuItem(
                              value: i,
                              child: Text(
                                stages[i],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          onChanged: (v) => setState(() => _stageIndex = v!),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _startEvaluation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('بدء التقييم'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }
}

// Forward declaration for the evaluation board
class EvaluationBoardScreen extends StatefulWidget {
  final String studentName;
  final int pageNumber;
  final int stageIndex;

  const EvaluationBoardScreen({
    super.key,
    required this.studentName,
    required this.pageNumber,
    required this.stageIndex,
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
        title: const Text('لوحة التقييم',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _sectionBadgeBg(entry.key),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${entry.key}',
                                style: TextStyle(
                                  color: _sectionBadgeText(entry.key),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              sectionTitle(entry.key),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Section Content
                      if (entry.key == 2 && s2TextOnly)
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
                      else if (entry.value.isEmpty && !s2Empty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'لا توجد أخطاء في هذا القسم',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        _buildSectionGrid(entry.key, entry.value),
                    ],
                  ),
                ),
            const SizedBox(height: 8),
            _LiveResultCard(
              errorButtons: _errors,
              counts: _counts,
              stageIndex: widget.stageIndex,
              studentName: widget.studentName,
              pageNumber: widget.pageNumber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionGrid(int section, List<ErrorButton> items) {
    final crossAxisCount = section == 1 ? 2 : 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: section == 1 ? 1.6 : 1.3,
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
        return const Color(0xFFFEF3C7);
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
        return const Color(0xFFD97706);
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
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ErrorTile({
    required this.err,
    required this.count,
    required this.isDisabled,
    required this.section,
    required this.onIncrement,
    required this.onDecrement,
  });

  Color get _bg {
    if (isDisabled) return const Color(0xFFF1F5F9);
    if (count > 0) {
      switch (section) {
        case 1:
          return const Color(0xFFFFE4E6);
        case 2:
          return const Color(0xFFFEF3C7);
        case 3:
          return const Color(0xFFDBEAFE);
        default:
          return Colors.grey.shade100;
      }
    }
    switch (section) {
      case 1:
        return const Color(0xFFFFF1F2);
      case 2:
        return const Color(0xFFFFFBEB);
      case 3:
        return const Color(0xFFEFF6FF);
      default:
        return Colors.grey.shade50;
    }
  }

  Color get _border {
    if (isDisabled) return const Color(0xFFE2E8F0);
    switch (section) {
      case 1:
        return const Color(0xFFFECDD3);
      case 2:
        return const Color(0xFFFDE68A);
      case 3:
        return const Color(0xFFBFDBFE);
      default:
        return Colors.grey.shade300;
    }
  }

  Color get _text {
    if (isDisabled) return const Color(0xFF94A3B8);
    switch (section) {
      case 1:
        return const Color(0xFFBE123C);
      case 2:
        return const Color(0xFFB45309);
      case 3:
        return const Color(0xFF1D4ED8);
      default:
        return Colors.grey.shade700;
    }
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
                _CounterRow(
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

class _CounterRow extends StatelessWidget {
  final int count;
  final double deduction;
  final bool isDisabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color borderColor;
  final Color textColor;

  const _CounterRow({
    required this.count,
    required this.deduction,
    required this.isDisabled,
    required this.onIncrement,
    required this.onDecrement,
    required this.borderColor,
    required this.textColor,
  });

  String _formatDeduction() {
    return formatDeductionValue(deductionForButton(count, deduction));
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
          _CounterButton(
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
          _CounterButton(
            icon: Icons.add,
            color: const Color(0xFF10B981),
            onTap: isDisabled ? null : onIncrement,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _CounterButton({
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
  final int pageNumber;

  const _LiveResultCard({
    required this.errorButtons,
    required this.counts,
    required this.stageIndex,
    required this.studentName,
    required this.pageNumber,
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
    final totalDeductions =
        totalDeductionForButtons(widget.errorButtons, widget.counts);
    final grade = computeGrade(widget.stageIndex, totalDeductions);

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
          // Header
          const Text(
            'نتيجة تقييم التلاوة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'تطبيق التقييم القرآني الرسمي',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          // Info Box
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
                _infoRow(Icons.tag, 'الصفحة', '${widget.pageNumber}'),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0xFFA7F3D0).withValues(alpha: 0.5),
                ),
                _infoRow(Icons.layers_outlined, 'المرحلة',
                    stages[widget.stageIndex]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Observations Section
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
                if (activeErrors.isEmpty)
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
                else
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
                          Text(e.name,
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 14)),
                          Text(
                            '${widget.counts[e.id] ?? 0}',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Final Grade
          const SizedBox(height: 20),
          const Text(
            'التقدير النهائي',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            grade,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 36,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final activeErrors = widget.errorButtons
                    .where((e) => (widget.counts[e.id] ?? 0) > 0)
                    .map((e) =>
                        ErrorEntry(name: e.name, count: widget.counts[e.id]!))
                    .toList();
                final totalDeductions = totalDeductionForButtons(
                    widget.errorButtons, widget.counts);
                final grade = computeGrade(widget.stageIndex, totalDeductions);
                await EvaluationStorage.saveResult(
                  EvaluationResult(
                    id: generateId(),
                    studentName: widget.studentName,
                    pageNumber: widget.pageNumber,
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
                    builder: (_) => ResultSummaryScreen(
                      studentName: widget.studentName,
                      pageNumber: widget.pageNumber,
                      stageIndex: widget.stageIndex,
                      errors: activeErrors,
                      errorButtons: widget.errorButtons,
                      counts: widget.counts,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ النتيجة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandTeal,
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

// Forward declaration for result summary
class ResultSummaryScreen extends StatefulWidget {
  final String studentName;
  final int pageNumber;
  final int stageIndex;
  final List<ErrorEntry> errors;
  final List<ErrorButton> errorButtons;
  final Map<String, int> counts;

  const ResultSummaryScreen({
    super.key,
    required this.studentName,
    required this.pageNumber,
    required this.stageIndex,
    required this.errors,
    required this.errorButtons,
    required this.counts,
  });

  static const gradeColors = {
    'تفوق': Color(0xFF059669),
    'ممتاز': Color(0xFF2563EB),
    'جيد جداً': Color(0xFFD97706),
    'جيد': Color(0xFFEA580C),
    'إعادة': Color(0xFFDC2626),
  };

  @override
  State<ResultSummaryScreen> createState() => _ResultSummaryScreenState();
}

class _ResultSummaryScreenState extends State<ResultSummaryScreen> {
  final GlobalKey _captureKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareAsImage() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw 'لم يتم العثور على البطاقة';
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw 'فشل تحويل الصورة';
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/evaluation_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'نتيجة تقييم ${widget.studentName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذرت المشاركة كصورة: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDeductions =
        totalDeductionForButtons(widget.errorButtons, widget.counts);

    final grade = computeGrade(widget.stageIndex, totalDeductions);
    final gradeColor = ResultSummaryScreen.gradeColors[grade] ?? Colors.grey;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        title: const Text('النتيجة', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _sharing ? null : _shareAsImage,
            icon: _sharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share, color: Color(0xFF1CA390)),
            tooltip: 'مشاركة كصورة',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RepaintBoundary(
              key: _captureKey,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
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
                    Text(
                      'نتيجة تقييم التلاوة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'بسم الله الرحمن الرحيم',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _infoRow('الطالب', widget.studentName),
                          const SizedBox(height: 10),
                          _infoRow('المرحلة', stages[widget.stageIndex]),
                          const SizedBox(height: 10),
                          _infoRow('رقم الصفحة', '${widget.pageNumber}'),
                          const Divider(height: 24),
                          _infoRow('التقدير', grade,
                              valueWidget: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: gradeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: gradeColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  grade,
                                  style: TextStyle(
                                    color: gradeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    if (widget.errors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'الأخطاء المسجلة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.errors.map(
                        (e) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.name,
                                  style:
                                      TextStyle(color: Colors.grey.shade700)),
                              Text(
                                '${e.count} مرات',
                                style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'تقويم التلاوة - إتقان للتعليم والتنمية',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ActionButtons(
              studentName: widget.studentName,
              pageNumber: widget.pageNumber,
              stageIndex: widget.stageIndex,
              errors: widget.errors,
              errorButtons: widget.errorButtons,
              counts: widget.counts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Widget? valueWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500)),
        valueWidget ??
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ActionButtons extends StatefulWidget {
  final String studentName;
  final int pageNumber;
  final int stageIndex;
  final List<ErrorEntry> errors;
  final List<ErrorButton> errorButtons;
  final Map<String, int> counts;

  const _ActionButtons({
    required this.studentName,
    required this.pageNumber,
    required this.stageIndex,
    required this.errors,
    required this.errorButtons,
    required this.counts,
  });

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _saved = true;

  Future<void> _save() async {
    final totalDeductions =
        totalDeductionForButtons(widget.errorButtons, widget.counts);
    final grade = computeGrade(widget.stageIndex, totalDeductions);

    await EvaluationStorage.saveResult(
      EvaluationResult(
        id: generateId(),
        studentName: widget.studentName,
        pageNumber: widget.pageNumber,
        stage: stages[widget.stageIndex],
        errors: widget.errors,
        totalDeductions: totalDeductions,
        grade: grade,
        timestamp: DateTime.now(),
      ),
    );

    if (mounted) {
      setState(() => _saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ النتيجة بنجاح')),
      );
    }
  }

  Future<void> _shareAsText() async {
    final buffer = StringBuffer();
    buffer.writeln('📖 نتيجة تقييم تلاوة القرآن');
    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    buffer.writeln('الطالب: ${widget.studentName}');
    buffer.writeln('المرحلة: ${stages[widget.stageIndex]}');
    buffer.writeln('رقم الصفحة: ${widget.pageNumber}');

    final totalDeductions =
        totalDeductionForButtons(widget.errorButtons, widget.counts);
    final grade = computeGrade(widget.stageIndex, totalDeductions);
    buffer.writeln('التقدير: $grade');

    if (widget.errors.isNotEmpty) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━');
      for (final e in widget.errors) {
        buffer.writeln('${e.name}: ${e.count} مرات');
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ النتيجة')),
      );
    }
  }

  Future<void> _shareAsImage() async {
    // Placeholder for image sharing - could use RepaintBoundary
    await _shareAsText();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_saved) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('حفظ النتيجة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('إلغاء التقييم',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _shareAsImage,
              icon: const Icon(Icons.share),
              label: const Text('مشاركة النتيجة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _shareAsText,
              icon: const Icon(Icons.copy),
              label: const Text('مشاركة كنص',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandTeal,
                side: const BorderSide(color: AppColors.brandTeal),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SetupFormScreen()),
                (route) => false,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('تقييم جديد',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
