import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/models/task_model.dart';
import 'package:burner_list/providers/task_provider.dart';
import 'package:burner_list/widgets/task_note_dialog.dart';

class SinkList extends ConsumerWidget {
  final List<Task> tasks;
  final String emptyMessage;

  const SinkList({
    super.key,
    required this.tasks,
    this.emptyMessage = 'The sink is empty!',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            emptyMessage,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: IconButton(
              icon: Icon(
                task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: task.isCompleted ? Colors.green : Colors.grey[400],
              ),
              onPressed: () {
                ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted ? Colors.grey : Colors.black87,
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
                if (value == 'note') {
                  showDialog(
                    context: context,
                    builder: (_) => TaskNoteDialog(task: task),
                  );
                } else if (value == 'delete') {
                  await ref.read(taskProvider.notifier).deleteTask(task.id);
                } else if (value == 'promote_front') {
                  await ref
                      .read(taskProvider.notifier)
                      .moveTask(task.id, TaskType.frontBurner);
                } else if (value == 'promote_back') {
                  await ref
                      .read(taskProvider.notifier)
                      .moveTask(task.id, TaskType.backBurner);
                } else if (value == 'move_counter') {
                  await ref
                      .read(taskProvider.notifier)
                      .moveTask(task.id, TaskType.counterSpace);
                } else if (value == 'demote_sink') {
                  await ref
                      .read(taskProvider.notifier)
                      .moveTask(task.id, TaskType.kitchenSink);
                }
              },
              itemBuilder: (BuildContext context) {
                final List<PopupMenuEntry<String>> items = [
                  PopupMenuItem<String>(
                    value: 'note',
                    child: Text(
                      task.note != null ? 'メモを編集' : 'メモを追加',
                    ),
                  ),
                  const PopupMenuDivider(),
                ];

                if (task.type != TaskType.frontBurner) {
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'promote_front',
                      child: Text('Promote to Front Burner'),
                    ),
                  );
                }

                if (task.type != TaskType.backBurner) {
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'promote_back',
                      child: Text('Promote to Back Burner'),
                    ),
                  );
                }

                if (task.type == TaskType.kitchenSink) {
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'move_counter',
                      child: Text('Move to Counter Space'),
                    ),
                  );
                }

                if (task.type == TaskType.counterSpace) {
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'demote_sink',
                      child: Text('Move to Sink'),
                    ),
                  );
                }

                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                );

                return items;
              },
            ),
          ),
        );
      },
    );
  }
}
