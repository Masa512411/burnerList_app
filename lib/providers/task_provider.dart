import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:burner_list/models/task_model.dart';
import 'package:burner_list/services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final taskProvider = NotifierProvider<TaskNotifier, List<Task>>(
  TaskNotifier.new,
);

class TaskNotifier extends Notifier<List<Task>> {
  late StorageService _storageService;
  final _uuid = const Uuid();

  @override
  List<Task> build() {
    _storageService = ref.read(storageServiceProvider);
    _loadTasks();
    return [];
  }

  Future<void> _loadTasks() async {
    final tasks = await _storageService.loadTasks();
    state = tasks;
  }

  Future<void> _saveTasks() async {
    await _storageService.saveTasks(state);
  }

  Future<void> addTask(
    String title, {
    TaskType type = TaskType.kitchenSink,
  }) async {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      type: TaskType.kitchenSink,
      createdAt: DateTime.now(),
    );

    state = [...state, newTask];

    if (type == TaskType.kitchenSink) {
      await _saveTasks();
    } else {
      // Route through moveTask so front/back burner displacement runs
      // even when adding directly into an occupied slot.
      await moveTask(newTask.id, type);
    }
  }

  Future<void> deleteTask(String id) async {
    state = state.where((t) => t.id != id).toList();
    await _saveTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = state.firstWhere((t) => t.id == id);
    final willComplete = !task.isCompleted;

    // 未完了に戻すとき、フロント/バーナーのスロットが既に別の未完了タスクで
    // 埋まっている場合はシンクへ移動する（同じスロットに複数入るのを防ぐ）。
    TaskType targetType = task.type;
    if (!willComplete &&
        (task.type == TaskType.frontBurner ||
            task.type == TaskType.backBurner)) {
      final slotOccupied = state.any(
        (t) => t.id != id && t.type == task.type && !t.isCompleted,
      );
      if (slotOccupied) {
        targetType = TaskType.kitchenSink;
      }
    }

    state = state.map((t) {
      if (t.id == id) {
        return t.copyWith(isCompleted: willComplete, type: targetType);
      }
      return t;
    }).toList();
    await _saveTasks();
  }

  Future<void> moveTask(String id, TaskType newType) async {
    List<Task> newState = [...state];
    final taskIndex = newState.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final task = newState[taskIndex];

    // Displacement Logic
    if (newType == TaskType.frontBurner) {
      // Check for existing front burner
      // Completed tasks are treated as empty slots by the UI, so ignore them
      // here as well to avoid demoting an active back burner unexpectedly.
      int? oldFrontIndex;
      for (var i = 0; i < newState.length; i++) {
        if (newState[i].type == TaskType.frontBurner &&
            newState[i].id != id &&
            !newState[i].isCompleted) {
          oldFrontIndex = i;
          break;
        }
      }

      if (oldFrontIndex != null) {
        // Demote old Front to Back
        newState[oldFrontIndex] = newState[oldFrontIndex].copyWith(
          type: TaskType.backBurner,
        );

        // Now check if we displaced a back burner
        // We need to find if there was ANOTHER back burner (not the one we just moved)
        // Actually, if we just moved oldFront to Back, we might now have TWO Back burners (the old front, and maybe an existing back).
        // We should find the *original* Back burner and demote it.

        for (var i = 0; i < newState.length; i++) {
          // If it's back burner, and it is NOT the one we just demoted, and NOT the one we are moving in
          if (newState[i].type == TaskType.backBurner &&
              i != oldFrontIndex &&
              newState[i].id != id &&
              !newState[i].isCompleted) {
            newState[i] = newState[i].copyWith(type: TaskType.kitchenSink);
          }
        }
      }
    } else if (newType == TaskType.backBurner) {
      // Demote existing Back Burner to Sink (completed tasks are treated as
      // empty slots by the UI, so they should not be displaced).
      for (int i = 0; i < newState.length; i++) {
        if (newState[i].type == TaskType.backBurner &&
            newState[i].id != id &&
            !newState[i].isCompleted) {
          newState[i] = newState[i].copyWith(type: TaskType.kitchenSink);
        }
      }
    }

    // Update the target task
    // We need to find the index again because it might have changed? No, list length is same.
    // But we might have modified the list in place.
    // Actually `newState` has valid indices.

    newState[taskIndex] = task.copyWith(type: newType);
    state = newState;
    await _saveTasks();
  }

  Future<void> updateTaskNote(String id, String? note) async {
    state = state.map((t) {
      if (t.id == id) {
        final trimmed = note?.trim();
        return t.copyWith(
          note: (trimmed != null && trimmed.isNotEmpty) ? trimmed : null,
          clearNote: trimmed == null || trimmed.isEmpty,
        );
      }
      return t;
    }).toList();
    await _saveTasks();
  }

  Future<void> reorderTasks(TaskType type, int oldIndex, int newIndex) async {
    // Must match the filtering the UI applies (pending, non-completed tasks)
    // so the indices passed in correspond to the same list being reordered.
    final typedTasks = state
        .where((t) => t.type == type && !t.isCompleted)
        .toList();
    if (oldIndex < newIndex) newIndex -= 1;
    final task = typedTasks.removeAt(oldIndex);
    typedTasks.insert(newIndex, task);

    int typedIndex = 0;
    final List<Task> newState = state.map((t) {
      if (t.type == type && !t.isCompleted) return typedTasks[typedIndex++];
      return t;
    }).toList();
    state = newState;
    await _saveTasks();
  }

  Future<void> archiveTask(String id) async {
    state = state.map((t) {
      if (t.id == id) return t.copyWith(isArchived: true);
      return t;
    }).toList();
    await _saveTasks();
  }

  Future<void> restoreTask(String id) async {
    state = state.map((t) {
      if (t.id == id) {
        return t.copyWith(
          isArchived: false,
          type: TaskType.kitchenSink,
          isCompleted: false,
        );
      }
      return t;
    }).toList();
    await _saveTasks();
  }

  Future<void> cleanSlate({List<String>? keepTaskIds}) async {
    if (keepTaskIds == null || keepTaskIds.isEmpty) {
      state = [];
    } else {
      state = state.where((t) => keepTaskIds.contains(t.id)).toList();
    }
    await _saveTasks();
  }
}
