import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../domain/entities/task.dart';
import '../../../data/models/task_model.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final TaskEntity? existingTask; 

  const TaskFormScreen({super.key, this.existingTask});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  TaskStatus _status = TaskStatus.todo;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  int? _selectedProjectId;
  int? _assignedToId;
  String? _assignedToName;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.existingTask!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _status = t.status;
      _priority = t.priority;
      _dueDate = t.dueDate;
      _selectedProjectId = t.projectId;
      _assignedToId = t.assignedToId;
      _assignedToName = t.assignedToName;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).loadAllUsers();
      ref.read(projectProvider.notifier).loadProjects();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  if (_selectedProjectId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a project')),
    );
    return;
  }

  final task = TaskModel(
    id: widget.existingTask?.id,
    title: _titleCtrl.text.trim(),
    description:
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    status: _status,
    priority: _priority,
    dueDate: _dueDate,
    projectId: _selectedProjectId!,
    creatorId: widget.existingTask?.creatorId,
    creatorName: widget.existingTask?.creatorName,
    assignedToId: _assignedToId,
    assignedToName: _assignedToName,
    isCollaborative: widget.existingTask?.isCollaborative ?? false,
    createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
  );

  bool success;
  if (_isEditing) {
    success = await ref.read(taskProvider.notifier).updateTask(task);
  } else {
    success = await ref.read(taskProvider.notifier).createTask(task);
  }

  if (success && mounted) {
    context.pop();
  }
}

  @override
Widget build(BuildContext context) {
  final projects = ref.watch(projectProvider).projects;
  final users = ref.watch(authProvider).allUsers;

  return SafeArea(  
    child: Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40), 
          children: [
            _SectionLabel('Title'),
            CustomTextField(
              controller: _titleCtrl,
              hint: 'e.g. Design homepage mockup',
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 18),
            _SectionLabel('Description (optional)'),
            CustomTextField(
              controller: _descCtrl,
              hint: 'Add more details...',
              maxLines: 3,
            ),
            const SizedBox(height: 18),
            _SectionLabel('Project'),
            DropdownButtonFormField<int>(
              value: _selectedProjectId,
              hint: const Text('Select a project'),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              items: projects.map((p) {
                return DropdownMenuItem(value: p.id, child: Text(p.name));
              }).toList(),
              onChanged: (v) => setState(() => _selectedProjectId = v),
            ),
            const SizedBox(height: 18),
            _SectionLabel('Priority'),
            _PrioritySelector(
              value: _priority,
              onChanged: (v) => setState(() => _priority = v),
            ),
            const SizedBox(height: 18),
            _SectionLabel('Status'),
            _StatusSelector(
              value: _status,
              onChanged: (v) => setState(() => _status = v),
            ),
            const SizedBox(height: 18),
            _SectionLabel('Due Date (optional)'),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ??
                      DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 2)),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) setState(() => _dueDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.textHint),
                    const SizedBox(width: 10),
                    Text(
                      _dueDate != null
                          ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                          : 'Select due date',
                      style: TextStyle(
                        color: _dueDate != null
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.textHint),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionLabel('Assign To (optional)'),
            DropdownButtonFormField<int>(
              value: _assignedToId,
              hint: const Text('Assign to a team member'),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
              ),
              items: users.map((u) {
                return DropdownMenuItem(
                  value: u.id,
                  child: Text(u.fullName),
                );
              }).toList(),
              onChanged: (v) {
                final user = users.firstWhere((u) => u.id == v);
                setState(() {
                  _assignedToId = v;
                  _assignedToName = user.fullName;
                });
              },
            ),
            const SizedBox(height: 36),
            CustomButton(
              label: _isEditing ? 'Save Changes' : 'Create Task',
              icon: _isEditing ? Icons.save_outlined : Icons.add,
              onPressed: _submit,
              isLoading: ref.watch(taskProvider).isLoading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
}
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;

  const _PrioritySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const priorities = [
      (TaskPriority.low, 'Low', AppColors.priorityLow),
      (TaskPriority.medium, 'Medium', AppColors.priorityMedium),
      (TaskPriority.high, 'High', AppColors.priorityHigh),
      (TaskPriority.urgent, 'Urgent', AppColors.priorityUrgent),
    ];

    return Row(
      children: priorities.map((p) {
        final isSelected = value == p.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(p.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? p.$3.withOpacity(0.15) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? p.$3 : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                p.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? p.$3 : AppColors.textHint,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final TaskStatus value;
  final ValueChanged<TaskStatus> onChanged;

  const _StatusSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const statuses = [
      (TaskStatus.todo, 'To Do', AppColors.info),
      (TaskStatus.inProgress, 'In Progress', AppColors.warning),
      (TaskStatus.done, 'Done', AppColors.success),
    ];

    return Row(
      children: statuses.map((s) {
        final isSelected = value == s.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? s.$3.withOpacity(0.12) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? s.$3 : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                s.$2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? s.$3 : AppColors.textHint,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}