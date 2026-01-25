import 'package:shared_preferences/shared_preferences.dart';
import 'package:burner_list/models/task_model.dart';

class StorageService {
  static const String _tasksKey = 'tasks';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedTasks = tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_tasksKey, encodedTasks);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedTasks = prefs.getStringList(_tasksKey);

    if (encodedTasks == null) {
      return [];
    }

    return encodedTasks.map((t) => Task.fromJson(t)).toList();
  }
}
