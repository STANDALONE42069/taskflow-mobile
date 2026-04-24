import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/project_card.dart';
import '../../../data/models/project_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProjectsFullPage extends ConsumerStatefulWidget {
  const ProjectsFullPage({super.key});

  @override
  ConsumerState<ProjectsFullPage> createState() => _ProjectsFullPageState();
}

class _ProjectsFullPageState extends ConsumerState<ProjectsFullPage> {
 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(projectProvider).projects.isEmpty) {
        ref.read(projectProvider.notifier).loadProjects();
      }
    });
  }

void _showCreateDialog() {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String selectedColor = '#9B1B30';

  final colors = [
    '#9B1B30', '#1565C0', '#2E7D32', '#F57C00',
    '#6A1B9A', '#00838F', '#4E342E', '#37474F'
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('New Project',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: nameCtrl,
                  hint: 'Project name',
                  prefixIcon: Icons.folder_outlined,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: descCtrl,
                  hint: 'Short description (optional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 18),
                const Text('Color',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: colors.map((c) {
                    final isSelected = selectedColor == c;
                    final color =
                        Color(int.parse(c.replaceFirst('#', '0xFF')));
                    return GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 6)
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Create Project',
                  icon: Icons.add,
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final userId = ref.read(authProvider).user!.id;
                    final project = ProjectModel(
                      name: nameCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                      colorHex: selectedColor,
                      ownerId: userId,
                      createdAt: DateTime.now(),
                    );
                    await ref
                        .read(projectProvider.notifier)
                        .createProject(project);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
Widget build(BuildContext context) {
  final projectState = ref.watch(projectProvider);

  return SafeArea(  
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primary),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: projectState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : projectState.projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_off_outlined,
                          size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('No projects yet',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 16)),
                      const SizedBox(height: 20),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 40),
                        child: CustomButton(
                          label: 'Create Project',
                          icon: Icons.add,
                          onPressed: _showCreateDialog,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                  itemCount: projectState.projects.length,
                  itemBuilder: (context, index) {
                    final project = projectState.projects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => context.push(
                          '/projects/detail',
                          extra: project),
                      onDelete: () => ref
                          .read(projectProvider.notifier)
                          .deleteProject(project.id!),
                    );
                  },
                ),
    ),
  );
}
}