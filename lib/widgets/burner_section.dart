import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/models/task_model.dart';
import 'package:burner_list/providers/task_provider.dart';
import 'package:burner_list/widgets/task_note_dialog.dart';

class BurnerSection extends ConsumerWidget {
  final String title;
  final TaskType type;
  final Task? task;
  final VoidCallback onAddPressed;

  const BurnerSection({
    super.key,
    required this.title,
    required this.type,
    this.task,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on type
    final Color borderColor = type == TaskType.frontBurner
        ? const Color(0xFFFF5722)
        : const Color(0xFF2196F3);

    // Icon背景はダークモードでは暗めのトーンにする
    final Color bgColor = type == TaskType.frontBurner
        ? (isDark ? const Color(0xFF4A2A1A) : const Color(0xFFFFF3E0))
        : (isDark ? const Color(0xFF1A3040) : const Color(0xFFE3F2FD));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: task == null ? onAddPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: task != null
                  ? colorScheme.surfaceContainerLowest
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 2,
                style: task != null
                    ? BorderStyle.solid
                    : BorderStyle
                          .none, // Dashed would need custom painter, solid/transparent for now
              ),
              boxShadow: task != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: task != null
                ? Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: CircleAvatar(
                          // Burner Flame Icon or similar
                          radius: 16,
                          backgroundColor: bgColor,
                          child: Icon(
                            Icons.local_fire_department,
                            color: borderColor,
                            size: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task!.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    decoration: task!.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task!.isCompleted
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurface,
                                  ),
                            ),
                            if (task!.note != null && task!.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  task!.note!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          task!.isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: task!.isCompleted
                              ? Colors.green
                              : colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          ref
                              .read(taskProvider.notifier)
                              .toggleTaskCompletion(task!.id);
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'note') {
                            showDialog(
                              context: context,
                              builder: (_) => TaskNoteDialog(task: task!),
                            );
                          } else if (value == 'archive') {
                            await ref
                                .read(taskProvider.notifier)
                                .archiveTask(task!.id);
                          } else if (value == 'delete') {
                            await ref
                                .read(taskProvider.notifier)
                                .deleteTask(task!.id);
                          } else if (value == 'demote') {
                            if (type == TaskType.frontBurner) {
                              await ref
                                  .read(taskProvider.notifier)
                                  .moveTask(task!.id, TaskType.backBurner);
                            } else {
                              await ref
                                  .read(taskProvider.notifier)
                                  .moveTask(task!.id, TaskType.kitchenSink);
                            }
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'note',
                                child: Text(
                                  task!.note != null ? 'メモを編集' : 'メモを追加',
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'demote',
                                child: Text(
                                  type == TaskType.frontBurner
                                      ? 'Move to Back Burner'
                                      : 'Move to Sink',
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem<String>(
                                value: 'archive',
                                child: Text('アーカイブ'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text(
                                  '削除',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'Empty Slot',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
