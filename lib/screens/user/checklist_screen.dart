import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/checklist_provider.dart';
import '../../services/checklist_api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';
import 'event_flow_home_screen.dart';
import 'profile_screen.dart';

const bool _skipChecklistBackend = bool.fromEnvironment(
  'SKIP_CHECKLIST_BACKEND',
  defaultValue: false,
);
const bool _skipCreateEventBackend = bool.fromEnvironment(
  'SKIP_CREATE_EVENT_BACKEND',
  defaultValue: false,
);

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key, this.eventName = 'Evergreen Events'});

  final String eventName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(checklistTasksProvider);
    final completed = tasks.where((task) => task.isCompleted).length;
    final upcoming = tasks.length - completed;
    final total = tasks.length;
    final percent = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      backgroundColor: AppColors.eventPageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _ChecklistHeader(title: eventName),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      _MilestoneCard(
                        completed: completed,
                        total: total,
                        percent: percent,
                      ),
                      const SizedBox(height: 24),
                      _ActiveChecklistHeader(upcoming: upcoming),
                      const SizedBox(height: 14),
                      for (final task in tasks) ...[
                        _TaskCard(
                          task: task,
                          onChanged: (value) {
                            _toggleTask(ref, task, value ?? false);
                          },
                          onDelete: () => _deleteTask(ref, task),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _AddTaskButton(
                        onPressed: () => _showAddTaskSheet(context, ref),
                      ),
                      const SizedBox(height: 180),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _ChecklistBottomNav(),
    );
  }

  void _toggleTask(WidgetRef ref, ChecklistTask task, bool isCompleted) {
    final updatedTasks = [
      for (final current in ref.read(checklistTasksProvider))
        if (current.id == task.id)
          current.copyWith(isCompleted: isCompleted)
        else
          current,
    ];
    ref.read(checklistTasksProvider.notifier).state = [
      ...updatedTasks.where((task) => !task.isCompleted),
      ...updatedTasks.where((task) => task.isCompleted),
    ];
  }

  void _deleteTask(WidgetRef ref, ChecklistTask task) {
    ref.read(checklistTasksProvider.notifier).state = [
      for (final current in ref.read(checklistTasksProvider))
        if (current.id != task.id) current,
    ];
  }

  Future<void> _showAddTaskSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(eventName: eventName),
    );
  }
}

class _ChecklistHeader extends StatelessWidget {
  const _ChecklistHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.eventBackground,
      child: Column(
        children: [
          SizedBox(
            height: 58,
            child: Row(
              children: [
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.eventBlack,
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineMd(
                      color: AppColors.eventBlack,
                    ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                  color: AppColors.eventBlack,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.eventBorder),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.completed,
    required this.total,
    required this.percent,
  });

  final int completed;
  final int total;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final percentText = '${(percent * 100).round()}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.eventPrimary, AppColors.eventPrimaryLight],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EVENT MILESTONE',
            style: AppTextStyles.labelSm(
              color: AppColors.eventSoftText,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$completed / $total Tasks\nCompleted',
                  style:
                      AppTextStyles.headlineLgMobile(
                        color: AppColors.onPrimary,
                      ).copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1.08,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: AppColors.onPrimary.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  percentText,
                  style: AppTextStyles.labelMd(
                    color: AppColors.onPrimary,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: percent.clamp(0, 1),
              backgroundColor: AppColors.onPrimary.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.eventSelectedBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveChecklistHeader extends StatelessWidget {
  const _ActiveChecklistHeader({required this.upcoming});

  final int upcoming;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'ACTIVE CHECKLIST',
            style: AppTextStyles.labelSm(
              color: AppColors.eventDarkIcon,
            ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.15),
          ),
        ),
        Text(
          'Upcoming: $upcoming',
          style: AppTextStyles.labelMd(
            color: AppColors.eventBlack,
          ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  final ChecklistTask task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.eventBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.eventBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.eventShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: onChanged,
            activeColor: AppColors.eventAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: AppTextStyles.labelMd(
                    color: AppColors.eventBlack,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due ${_formatDate(task.dueDate)}',
                  style: AppTextStyles.labelSm(
                    color: AppColors.eventMutedForeground,
                  ).copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete task',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.eventMutedForeground,
          ),
        ],
      ),
    );
  }
}

class _AddTaskButton extends StatelessWidget {
  const _AddTaskButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.outlineVariant,
            radius: AppRadius.lg,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.eventMutedBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 21,
                    color: AppColors.eventBlack,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Add Task',
                  style: AppTextStyles.labelMd(
                    color: AppColors.eventBlack,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  const _AddTaskSheet({required this.eventName});

  final String eventName;

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _taskController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  var _isSubmitting = false;

  bool get _useLocalChecklistData =>
      _skipChecklistBackend || _skipCreateEventBackend;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    final name = _taskController.text.trim();
    if (name.isEmpty) {
      _showMessage('Enter a task name first.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final task = _useLocalChecklistData
          ? ChecklistTask.local(name: name, dueDate: _dueDate)
          : await ref
                .read(checklistApiServiceProvider)
                .createTask(
                  CreateChecklistTaskRequest(
                    eventName: widget.eventName,
                    name: name,
                    dueDate: _dueDate,
                  ),
                );

      final existingTasks = ref.read(checklistTasksProvider);
      ref.read(checklistTasksProvider.notifier).state = [
        ...existingTasks.where((task) => !task.isCompleted),
        task,
        ...existingTasks.where((task) => task.isCompleted),
      ];

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.eventBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.eventBorder,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Add Task',
                style: AppTextStyles.headlineMd(
                  color: AppColors.eventBlack,
                ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _taskController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'E.g. Confirm florist booking',
                  filled: true,
                  fillColor: AppColors.eventMutedBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Text(_formatDate(_dueDate)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.eventBlack,
                  side: const BorderSide(color: AppColors.eventBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.onPrimary,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Icon(Icons.add_task_rounded),
                  label: Text(_isSubmitting ? 'Adding...' : 'Create Task'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.eventPrimary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    textStyle: AppTextStyles.labelMd(
                      color: AppColors.onPrimary,
                    ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChecklistBottomNav extends StatelessWidget {
  const _ChecklistBottomNav();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
        decoration: const BoxDecoration(
          color: AppColors.eventBackground,
          border: Border(top: BorderSide(color: AppColors.eventBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const EventFlowHomeScreen(),
                  ),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
            const _BottomNavItem(
              icon: Icons.fact_check_rounded,
              label: 'Checklist',
              active: true,
            ),
            _BottomNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.eventPrimary
        : AppColors.eventMutedForeground;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.eventSelectedBackground
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSm(color: color).copyWith(
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 7.0;
      const gap = 5.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
