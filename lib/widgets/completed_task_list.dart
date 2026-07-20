import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/models/task_model.dart';
import 'package:burner_list/providers/task_provider.dart';

class CompletedTaskList extends ConsumerWidget {
  final List<Task> tasks;

  const CompletedTaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            '完了したタスクはありません',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          key: ValueKey(task.id),
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0,
          color: colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: ListTile(
            leading: IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: '未完了に戻す',
              onPressed: () {
                ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
              },
            ),
            title: Text(
              task.title,
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
            subtitle: task.note != null && task.note!.isNotEmpty
                ? Text(
                    task.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  )
                : null,
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'archive') {
                  await ref.read(taskProvider.notifier).archiveTask(task.id);
                } else if (value == 'delete') {
                  await ref.read(taskProvider.notifier).deleteTask(task.id);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem<String>(value: 'archive', child: Text('アーカイブ')),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('削除', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
