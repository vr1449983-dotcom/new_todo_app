import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../db/todo_firebase_database.dart';
import '../model/sync_mod.dart';
import '../model/todo_model.dart';

import '../services/category_firestore_service.dart';
import '../services/settings_service.dart';
import '../services/sync_service.dart';
import '../services/user_settings_service.dart' hide SettingsService;

enum SortOption { date, myOrder, recently, title }

class TodoController extends GetxController {

  /// ================================
  /// STATE
  /// ================================

  final RxList<TodoModel> todos = <TodoModel>[].obs;

  final RxList<String> categories = <String>[
    'All',
    'Starred',
    'Pending',
    'Completed',
  ].obs;

  final RxList<String> customCategories = <String>[].obs;

  final Rx<SyncMode> syncMode = SyncMode.automatic.obs;

  final RxString selectedCategory = 'All'.obs;

  final Rx<SortOption> selectedSort = SortOption.myOrder.obs;

  final RxBool selectionMode = false.obs;

  final RxList<String> selectedIds = <String>[].obs;

  /// ================================
  /// INIT
  /// ================================

  @override
  void onInit() {
    super.onInit();

    fetchCategories();
    _loadSyncMode();
    _startAutoSync();

    /// Listen todos
    TodoFirestoreService.streamTodos().listen((data) {
      todos.assignAll(data);
      _updateCategories(data);
    });

    /// Auto delete trash
    TodoFirestoreService.autoDeleteOldTrash();

    /// Listen categories
    CategoryFirestoreService.streamCategories().listen((cats) {
      customCategories.assignAll(cats);
      _mergeFirestoreCategories(cats);
    });
  }

  /// ================================
  /// SYNC
  /// ================================

  void _startAutoSync() {
    Connectivity().onConnectivityChanged.listen((event) async {
      final isOnline = event != ConnectivityResult.none;

      if (!isOnline) return;

      if (syncMode.value == SyncMode.automatic) {
        await SyncService.syncTodos();
        print("Auto Sync Done");
      }
    });
  }

  Future<void> _loadSyncMode() async {
    syncMode.value = await SettingsService.getSyncMode();
  }

  Future<void> changeSyncMode(SyncMode mode) async {
    syncMode.value = mode;

    await SettingsService.setSyncMode(mode);

    Future<void> changeSyncMode(SyncMode mode) async {
      syncMode.value = mode;

      // Save locally (optional)
      await SettingsService.setSyncMode(mode);

      // Save to Firestore (MAIN SOURCE)
      await UserSettingsService.saveSettings({
        "syncMode": mode.name,
      });
    }
  }

  /// ================================
  /// CATEGORY
  /// ================================

  Future<void> fetchCategories() async {
    final dbCats = await CategoryFirestoreService.getCategories();
    customCategories.assignAll(dbCats);
  }

  void addCategory(String name) async {
    final value = name.trim();
    if (value.isEmpty || value == 'All') return;

    await CategoryFirestoreService.addCategory(value);
  }

  void renameCategory(String oldName, String newName) async {
    final value = newName.trim();
    if (oldName == 'All' || value.isEmpty) return;

    await CategoryFirestoreService.renameCategory(oldName, value);
  }

  void deleteCategory(String name) async {
    if (name == 'All') return;

    await CategoryFirestoreService.deleteCategory(name);
  }

  void _updateCategories(List<TodoModel> data) {
    final updated = ['All'];

    if (data.any((e) => e.isStarred ?? false)) updated.add('Starred');
    if (data.any((e) => !(e.isDone ?? false))) updated.add('Pending');
    if (data.any((e) => e.isDone ?? false)) updated.add('Completed');

    final customCats = data
        .map((e) => e.category)
        .where((c) => c != null && c != 'All')
        .toSet()
        .toList();

    for (var cat in customCats) {
      if (!updated.contains(cat)) updated.add(cat!);
    }

    categories.assignAll(updated);
  }

  void _mergeFirestoreCategories(List<String> firestoreCats) {
    final merged = [...categories];

    for (var cat in firestoreCats) {
      if (!merged.contains(cat)) merged.add(cat);
    }

    categories.assignAll(merged);
  }

  /// ================================
  /// SELECTION
  /// ================================

  void startSelection(String id) {
    selectionMode.value = true;
    if (!selectedIds.contains(id)) selectedIds.add(id);
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }

    if (selectedIds.isEmpty) selectionMode.value = false;
  }

  void clearSelection() {
    selectedIds.clear();
    selectionMode.value = false;
  }

  void toggleSelectAll(List<String> ids) {
    if (selectedIds.length == ids.length) {
      selectedIds.clear();
    } else {
      selectedIds.assignAll(ids);
    }
  }

  Future<void> deleteSelected() async {
    for (var id in selectedIds) {
      await TodoFirestoreService.moveToTrash(id);
    }
    clearSelection();
  }

  Future<void> pinSelected() async {
    for (var id in selectedIds) {
      final todo = todos.firstWhereOrNull((e) => e.id == id);
      if (todo != null) {
        await TodoFirestoreService.toggleStar(id, todo.isStarred ?? false);
      }
    }
    clearSelection();
  }

  TodoModel? getSelectedTodo() {
    if (selectedIds.length != 1) return null;
    return todos.firstWhereOrNull((e) => e.id == selectedIds.first);
  }

  /// ================================
  /// FILTER + SORT
  /// ================================

  List<TodoModel> get sortedTodos {
    final filtered = _filterByCategory();

    filtered.sort((a, b) {
      if ((a.isStarred ?? false) && !(b.isStarred ?? false)) return -1;
      if (!(a.isStarred ?? false) && (b.isStarred ?? false)) return 1;

      switch (selectedSort.value) {
        case SortOption.date:
          return a.dateTime!.compareTo(b.dateTime!);

        case SortOption.recently:
          return b.dateTime!.compareTo(a.dateTime!);

        case SortOption.title:
          return a.title!
              .toLowerCase()
              .compareTo(b.title!.toLowerCase());

        case SortOption.myOrder:
          return 0;
      }
    });

    return filtered;
  }

  List<TodoModel> _filterByCategory() {
    switch (selectedCategory.value) {
      case 'Starred':
        return todos.where((t) => t.isStarred ?? false).toList();

      case 'Pending':
        return todos.where((t) => !(t.isDone ?? false)).toList();

      case 'Completed':
        return todos.where((t) => t.isDone ?? false).toList();

      default:
        if (selectedCategory.value == 'All') return todos;

        return todos
            .where((t) => t.category == selectedCategory.value)
            .toList();
    }
  }
}