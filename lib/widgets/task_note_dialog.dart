import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/models/task_model.dart';
import 'package:burner_list/providers/task_provider.dart';

class TaskNoteDialog extends ConsumerStatefulWidget {
  final Task task;

  const TaskNoteDialog({super.key, required this.task});

  @override
  ConsumerState<TaskNoteDialog> createState() => _TaskNoteDialogState();
}

class _TaskNoteDialogState extends ConsumerState<TaskNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.note ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(taskProvider.notifier)
        .updateTaskNote(widget.task.id, _controller.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.task.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: 'メモを入力...',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        textInputAction: TextInputAction.newline,
      ),
      actions: [
        if (widget.task.note != null)
          TextButton(
            onPressed: () {
              ref
                  .read(taskProvider.notifier)
                  .updateTaskNote(widget.task.id, null);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
