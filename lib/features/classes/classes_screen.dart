import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/app_state.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  bool _showAddForm = false;
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadClasses();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    super.dispose();
  }

  void _submitAdd() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final name = _nameController.text.trim();
    final teacher = _teacherController.text.trim();
    context.read<AppState>().addClass(name, teacher).then((_) {
      if (mounted) {
        _nameController.clear();
        _teacherController.clear();
        setState(() {
          _showAddForm = false;
          _isSubmitting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final classes = context.watch<AppState>().classes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحلقات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showAddForm = true),
            icon: const Icon(Icons.add, color: AppColors.brandTeal),
            label: const Text(
              'إضافة حلقة',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.brandBlue,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showAddForm) _buildAddForm(),
          Expanded(child: _buildBody(classes)),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'اسم الحلقة',
                  hintText: 'مثال: حلقة الفجر',
                  isDense: true,
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'مطلوب' : null,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _teacherController,
                decoration: const InputDecoration(
                  labelText: 'اسم المعلم',
                  hintText: 'مثال: محمد الرزوق',
                  isDense: true,
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onFieldSubmitted: (_) => _submitAdd(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            _nameController.clear();
                            _teacherController.clear();
                            setState(() => _showAddForm = false);
                          },
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAdd,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('حفظ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List classes) {
    if (classes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 64, color: AppColors.divider),
            SizedBox(height: 16),
            Text(
              'لا يوجد حلقات',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final cls = classes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              '/class',
              arguments: cls.id,
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.brandTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.class_outlined,
                        color: AppColors.brandTeal, size: 35),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cls.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandBlue,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              cls.teacherName.isEmpty
                                  ? 'لم يُحدد المعلم'
                                  : cls.teacherName,
                              style: TextStyle(
                                fontSize: 16,
                                color: cls.teacherName.isEmpty
                                    ? AppColors.divider
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _ClassDeleteMenu(classId: cls.id),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ClassDeleteMenu extends StatefulWidget {
  final int classId;

  const _ClassDeleteMenu({required this.classId});

  @override
  State<_ClassDeleteMenu> createState() => _ClassDeleteMenuState();
}

class _ClassDeleteMenuState extends State<_ClassDeleteMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon:
          const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 22),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.statusRed, size: 20),
              SizedBox(width: 8),
              Text('حذف الحلقة'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'delete') {
          _showConfirm();
        }
      },
    );
  }

  void _showConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text(
          'سيتم حذف الحلقة وجميع الطلاب والاختبارات المرتبطة بها. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRed,
            ),
            onPressed: () {
              context.read<AppState>().deleteClass(widget.classId);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
