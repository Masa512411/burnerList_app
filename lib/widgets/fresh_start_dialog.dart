import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/models/task_model.dart';
import 'package:burner_list/providers/task_provider.dart';

class FreshStartDialog extends ConsumerStatefulWidget {
  const FreshStartDialog({super.key});

  @override
  ConsumerState<FreshStartDialog> createState() => _FreshStartDialogState();
}

class _FreshStartDialogState extends ConsumerState<FreshStartDialog> {
  final Set<String> _selectedTaskIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    // Filter out completed tasks? Or show all?
    // User probably wants to see everything to decide what to keep.
    // Let's sort by type (Front, Back, Counter, Sink) for better visibility.
    final sortedTasks = [...tasks];
    sortedTasks.sort((a, b) => a.type.index.compareTo(b.type.index));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.cleaning_services, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Fresh Start',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isSelectionMode
                  ? 'Select tasks to carry over.'
                  : 'Clear your board to focus on what matters now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (_isSelectionMode) ...[
              Expanded(
                child: sortedTasks.isEmpty
                    ? const Center(child: Text('No tasks to carry over.'))
                    : ListView.builder(
                        itemCount: sortedTasks.length,
                        itemBuilder: (context, index) {
                          final task = sortedTasks[index];
                          final isSelected = _selectedTaskIds.contains(task.id);
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedTaskIds.add(task.id);
                                } else {
                                  _selectedTaskIds.remove(task.id);
                                }
                              });
                            },
                            title: Text(task.title),
                            subtitle: Text(_getTaskTypeLabel(task.type)),
                            secondary: _getTaskIcon(task.type),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        // Toggle select all
                        if (_selectedTaskIds.length == sortedTasks.length) {
                          _selectedTaskIds.clear();
                        } else {
                          _selectedTaskIds.addAll(sortedTasks.map((t) => t.id));
                        }
                      });
                    },
                    child: Text(
                      _selectedTaskIds.length == sortedTasks.length
                          ? 'Deselect All'
                          : 'Select All',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref
                      .read(taskProvider.notifier)
                      .cleanSlate(keepTaskIds: _selectedTaskIds.toList());
                  Navigator.pop(context);
                },
                child: Text(
                  'Keep ${_selectedTaskIds.length} Tasks & Wipe Rest',
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isSelectionMode = false),
                child: const Text('Back'),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: () {
                  // Direct Wipe All
                  ref.read(taskProvider.notifier).cleanSlate();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_forever),
                label: const Text('Wipe Everything'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isSelectionMode = true;
                  });
                },
                icon: const Icon(Icons.checklist),
                label: const Text('Select Tasks to Carry Over'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTaskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.frontBurner:
        return 'Front Burner';
      case TaskType.backBurner:
        return 'Back Burner';
      case TaskType.counterSpace:
        return 'Counter Space';
      case TaskType.kitchenSink:
        return 'Kitchen Sink';
    }
  }

  Widget _getTaskIcon(TaskType type) {
    switch (type) {
      case TaskType.frontBurner:
        return const Icon(Icons.local_fire_department, color: Colors.orange);
      case TaskType.backBurner:
        return const Icon(Icons.waves, color: Colors.blue);
      case TaskType.counterSpace:
        return const Icon(Icons.countertops, color: Colors.purple);
      case TaskType.kitchenSink:
        return const Icon(Icons.kitchen, color: Colors.grey);
    }
  }
}
