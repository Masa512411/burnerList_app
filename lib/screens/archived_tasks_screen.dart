import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/providers/task_provider.dart';

class ArchivedTasksScreen extends ConsumerWidget {
  const ArchivedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedTasks = ref
        .watch(taskProvider)
        .where((t) => t.isArchived)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'アーカイブ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          if (archivedTasks.isNotEmpty)
            TextButton(
              onPressed: () => _confirmDeleteAll(context, ref, archivedTasks.map((t) => t.id).toList()),
              child: const Text('すべて削除', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: archivedTasks.isEmpty
          ? const Center(
              child: Text(
                'アーカイブされたタスクはありません',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: archivedTasks.length,
              itemBuilder: (context, index) {
                final task = archivedTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.archive_outlined, color: Colors.grey),
                    title: Text(
                      task.title,
                      style: const TextStyle(color: Colors.black87),
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
                        if (value == 'restore') {
                          await ref.read(taskProvider.notifier).restoreTask(task.id);
                        } else if (value == 'delete') {
                          await ref.read(taskProvider.notifier).deleteTask(task.id);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem<String>(
                          value: 'restore',
                          child: Text('Kitchen Sinkに戻す'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('削除', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref, List<String> ids) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('アーカイブを全削除'),
        content: const Text('アーカイブされたすべてのタスクを削除します。この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              for (final id in ids) {
                await ref.read(taskProvider.notifier).deleteTask(id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
