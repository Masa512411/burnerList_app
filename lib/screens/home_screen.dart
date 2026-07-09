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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

    final activeTasks = tasks.where((t) => !t.isArchived).toList();

    Task? frontBurnerTask;
    Task? backBurnerTask;

    try {
      frontBurnerTask = activeTasks.firstWhere(
        (t) => t.type == TaskType.frontBurner,
      );
    } catch (_) {}

    try {
      backBurnerTask = activeTasks.firstWhere(
        (t) => t.type == TaskType.backBurner,
      );
    } catch (_) {}

    final sinkTasks = activeTasks
        .where((t) => t.type == TaskType.kitchenSink)
        .toList();

    final counterTasks = activeTasks
        .where((t) => t.type == TaskType.counterSpace)
        .toList();

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
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: <Widget>[
                SingleChildScrollView(
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
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.deepPurple,
                            ),
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
                        taskType: TaskType.counterSpace,
                        emptyMessage: 'No ideas in the counter space.',
                      ),
                      const SizedBox(height: 24),
                      BurnerSection(
                        title: 'Back Burner',
                        type: TaskType.backBurner,
                        task: backBurnerTask,
                        onAddPressed: () => _showAddTaskDialog(
                          context,
                          initialType: TaskType.backBurner,
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'KITCHEN SINK',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.orange,
                            ),
                            onPressed: () => _showAddTaskDialog(
                              context,
                              initialType: TaskType.kitchenSink,
                            ),
                            tooltip: 'Add to Sink',
                          ),
                        ],
                      ),
                      SinkList(
                        tasks: sinkTasks,
                        taskType: TaskType.kitchenSink,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.deepPurple : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
