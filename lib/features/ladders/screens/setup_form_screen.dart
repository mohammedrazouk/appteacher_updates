import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/errors_data.dart';
import '../data/storage_helper.dart';
import 'evaluation_board_screen.dart';
import 'history_view_screen.dart';
import 'tajweed_theory_screen.dart';

class SetupFormScreen extends StatefulWidget {
  const SetupFormScreen({super.key});

  @override
  State<SetupFormScreen> createState() => _SetupFormScreenState();
}

class _SetupFormScreenState extends State<SetupFormScreen> {
  final _nameController = TextEditingController();
  int _stageIndex = 0;
  String? _nameError;
  int _resultsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final results = await LadderStorage.loadResults();
    if (mounted) setState(() => _resultsCount = results.length);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEvaluation() {
    setState(() {
      _nameError = null;
    });

    final name = _nameController.text.trim();
    bool valid = true;

    if (name.isEmpty) {
      _nameError = 'الرجاء إدخال اسم الطالب';
      valid = false;
    }
    if (!valid) {
      setState(() {});
      return;
    }

    if (_stageIndex >= 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TajweedTheoryScreen(
            studentName: name,
            stageIndex: _stageIndex,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EvaluationBoardScreen(
            studentName: name,
            stageIndex: _stageIndex,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        'سلالم الاختبار',
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
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.history,
                                        size: 25, color: Color(0xFF1CA390)),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'سجل النتائج',
                                      style: TextStyle(
                                        color: Color(0xFF1CA390),
                                        fontSize: 18,
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
                        const _FieldLabel(text: 'الاختبار'),
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
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _startEvaluation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('بدء الاختبار'),
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
