import 'package:new_todo_app/services/settings_service.dart';

import '../db/todo_database.dart';
import '../db/todo_firebase_database.dart';
import '../model/sync_mod.dart';

class SyncService {
  static Future<void> syncTodos() async {

    final mode = await SettingsService.getSyncMode();

    if (mode == SyncMode.off) {
      print("Sync is OFF");
      return;
    }

    final localTodos = await TodoDatabase.getTodos();

    for (var todo in localTodos) {

      if (!(todo.isSynced ?? false) && !(todo.isDeleted ?? false)) {
        await TodoFirestoreService.insertTodo(todo);

        todo.isSynced = true;
        await TodoDatabase.updateTodo(todo);
      }

      else if (todo.isUpdated ?? false) {
        await TodoFirestoreService.updateTodo(todo);

        todo.isUpdated = false;
        await TodoDatabase.updateTodo(todo);
      }

      else if (todo.isDeleted ?? false) {
        await TodoFirestoreService.deleteTodo(todo.id!);
        await TodoDatabase.deleteTodo(todo.id!);
      }
    }

    final remoteTodos = await TodoFirestoreService.getTodos();

    for (var remote in remoteTodos) {
      await TodoDatabase.insertTodo(
        remote.copyWith(isSynced: true),
      );
    }
  }
}