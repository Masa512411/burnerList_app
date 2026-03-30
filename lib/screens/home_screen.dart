import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/models/task_model.dart';
import 'package:burner_list/providers/task_provider.dart';
import 'package:burner_list/screens/settings_screen.dart';
import 'package:burner_list/widgets/burner_section.dart';
import 'package:burner_list/widgets/sink_list.dart';
import 'package:burner_list/widgets/fresh_start_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _showAddTaskDialog(
    BuildContext context, {
    TaskType initialType = TaskType.kitchenSink,
  }) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            initialType == TaskType.frontBurner
                ? 'Add to Front Burner'
                : initialType == TaskType.backBurner
                ? 'Add to Back Burner'
                : initialType == TaskType.counterSpace
                ? 'Add to Counter Space'
                : 'Add to Kitchen Sink',
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'What needs to be done?',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submitTask(controller.text, initialType),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => _submitTask(controller.text, initialType),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _submitTask(String title, TaskType type) {
    if (title.trim().isEmpty) return;

    ref.read(taskProvider.notifier).addTask(title, type: type);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    // Find burner tasks
    // We assume 0 or 1 task per burner for simplicity in finding them,
    // but the list might contain multiple if we forced it.
    // We'll take the first one found or null.

    Task? frontBurnerTask;
    Task? backBurnerTask;

    try {
      frontBurnerTask = tasks.firstWhere((t) => t.type == TaskType.frontBurner);
    } catch (_) {}

    try {
      backBurnerTask = tasks.firstWhere((t) => t.type == TaskType.backBurner);
    } catch (_) {}

    // Kitchen sink tasks
    final sinkTasks = tasks
        .where((t) => t.type == TaskType.kitchenSink)
        .toList();
    // Sort sink tasks by creation date (newest first? or oldest first? usually lists are append at bottom)
    // Let's do newest first for now.
    sinkTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Counter Space tasks
    final counterTasks = tasks
        .where((t) => t.type == TaskType.counterSpace)
        .toList();
    counterTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Burner List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Fresh Start',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const FreshStartDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '設定',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BurnerSection(
              title: 'Front Burner',
              type: TaskType.frontBurner,
              task: frontBurnerTask,
              onAddPressed: () => _showAddTaskDialog(
                context,
                initialType: TaskType.frontBurner,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COUNTER SPACE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                  onPressed: () => _showAddTaskDialog(
                    context,
                    initialType: TaskType.counterSpace,
                  ),
                  tooltip: 'Add to Counter Space',
                ),
              ],
            ),
            SinkList(
              tasks: counterTasks,
              emptyMessage: 'No ideas in the counter space.',
            ),
            const SizedBox(height: 24),
            BurnerSection(
              title: 'Back Burner',
              type: TaskType.backBurner,
              task: backBurnerTask,
              onAddPressed: () =>
                  _showAddTaskDialog(context, initialType: TaskType.backBurner),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KITCHEN SINK',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.orange),
                  onPressed: () => _showAddTaskDialog(
                    context,
                    initialType: TaskType.kitchenSink,
                  ),
                  tooltip: 'Add to Sink',
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            SinkList(tasks: sinkTasks),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
