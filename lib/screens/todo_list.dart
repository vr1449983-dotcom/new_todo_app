import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:new_todo_app/db/todo_firebase_database.dart';
import '../controller/profile_controller.dart';
import '../controller/todo_controller.dart';
import '../model/todo_model.dart';
import 'profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final TodoController controller = Get.put(TodoController());
  final Map<String, GlobalKey> _tabKeys = {};

  void _confirmDeleteSelected() {

    final ids = controller.selectedIds.toList();

    Get.dialog(
      AlertDialog(
        title: const Text("Delete Tasks"),
        content: Text("Delete ${ids.length} selected tasks?"),
        actions: [

          TextButton(
            onPressed: Get.back,
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              Get.back(); // close dialog first

              for (var id in ids) {
                await TodoFirestoreService.moveToTrash(id);
              }

              controller.clearSelection();

              Get.snackbar(
                "Moved to Trash",
                "Undo available for 5 seconds",
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 5),
                backgroundColor:Theme.of(context).colorScheme.inverseSurface,
                colorText:Theme.of(context).colorScheme.onInverseSurface,
                margin: const EdgeInsets.all(12),
                borderRadius: 10,
                mainButton: TextButton(
                  onPressed: () {
                    for (var id in ids) {
                      TodoFirestoreService.restoreTodo(id);
                    }
                  },
                  child: const Text(
                    "UNDO",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              );
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }


  void _openCustomizeCategories() {
    final TextEditingController categoryCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customize Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            /// Add Category Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: categoryCtrl,
                    decoration: InputDecoration(
                      hintText: "New category name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                TextButton.icon(
                  onPressed: () {
                    final text = categoryCtrl.text.trim();
                    if (text.isNotEmpty) {
                      controller.addCategory(text);
                      categoryCtrl.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),

            Divider(color: Theme.of(context).colorScheme.outlineVariant),

            /// Categories List
            Expanded(
              child: Obx(
                    () {
                  // Build list: first 4 default, then Firestore custom
                  final defaultCategories = ["All", "Starred", "Pending", "Completed"];
                  final custom = controller.customCategories;

                  final totalCount = defaultCategories.length + custom.length;

                  return ListView.builder(
                    itemCount: totalCount,
                    itemBuilder: (_, i) {
                      String cat;
                      bool isDefault = i < 4;

                      if (isDefault) {
                        cat = defaultCategories[i];
                      } else {
                        cat = custom[i - 4];
                      }

                      // Default categories cannot be renamed/deleted
                      if (isDefault) {
                        return ListTile(title: Text(cat));
                      }

                      // Custom category UI
                      return ListTile(
                        title: Text(cat),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Rename button
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                final renameCtrl = TextEditingController(text: cat);
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text("Rename Category"),
                                    content: TextField(controller: renameCtrl),
                                    actions: [
                                      TextButton(
                                        onPressed: Get.back,
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final newName = renameCtrl.text.trim();
                                          if (newName.isNotEmpty) {
                                            controller.renameCategory(cat, newName);
                                          }
                                          Get.back();
                                        },
                                        child: const Text("Save"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                controller.deleteCategory(cat);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(TodoModel todo) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {

              Get.back(); // CLOSE DIALOG FIRST

              await TodoFirestoreService.moveToTrash(todo.id!);

              Get.snackbar(
                "Moved to Trash",
                "Undo available for 5 seconds",
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 5),
                backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                colorText: Theme.of(context).colorScheme.onInverseSurface,
                margin: const EdgeInsets.all(12),
                borderRadius: 10,
                mainButton: TextButton(
                  onPressed: () {
                    TodoFirestoreService.restoreTodo(todo.id!);
                  },
                  child: const Text(
                    "UNDO",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              );

            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({TodoModel? todo}) {
    final titleCtrl = TextEditingController(text: todo?.title ?? '');
    DateTime dateTime = todo?.dateTime ?? DateTime.now();

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: Text(todo == null ? 'Add Task' : 'Edit Task'),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM yyyy hh:mm a').format(dateTime),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: dateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (date == null) return;

                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(dateTime),
                        );

                        if (time == null) return;

                        setStateDialog(() {
                          dateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

            actions: [
              TextButton(onPressed: Get.back, child: const Text('Cancel')),

              ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;

                  final newTodo = TodoModel(
                    id: todo?.id,
                    title: titleCtrl.text.trim(),
                    dateTime: dateTime,
                    isDone: todo?.isDone ?? false,
                    isStarred: todo?.isStarred ?? false,
                    category:
                        todo?.category ?? controller.selectedCategory.value,
                  );

                  if (todo == null) {
                    TodoFirestoreService.insertTodo(newTodo);
                  } else {
                    TodoFirestoreService.updateTodo(newTodo);
                  }

                  Get.back();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tabs() {
    return Obx(() {
      final theme = Theme.of(context);

      // Build dynamic tabs
      final dynamicTabs = <String>[];

      // Always keep All
      dynamicTabs.add('All');

      // Default dynamic categories
      final hasStarred = controller.todos.any((e) => e.isStarred ?? false);
      final hasPending = controller.todos.any((e) => !(e.isDone ?? false));
      final hasCompleted = controller.todos.any((e) => e.isDone ?? false);

      if (hasStarred) dynamicTabs.add('Starred');
      if (hasPending) dynamicTabs.add('Pending');
      if (hasCompleted) dynamicTabs.add('Completed');

      // Custom categories from Firestore + todos
      final customCategories = controller.customCategories;
      dynamicTabs.addAll(customCategories);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // ⚙ Customize icon as bordered button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: _openCustomizeCategories,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline, // theme matched border
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: theme.colorScheme.surface, // same background as tabs
                  ),
                  child: Icon(
                    Icons.settings,
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
            ),

            // All other category tabs
            ...dynamicTabs.map((tab) {
              final selected = controller.selectedCategory.value == tab;

              _tabKeys.putIfAbsent(tab, () => GlobalKey());

              return Padding(
                key: _tabKeys[tab], // IMPORTANT
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(tab),
                  selected: selected,
                  selectedColor: theme.colorScheme.primaryContainer,
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 1.2,
                  ),
                  onSelected: (_) {
                    controller.selectedCategory.value = tab;

                    // 🔥 SCROLL TO CENTER
                    Future.delayed(const Duration(milliseconds: 100), () {
                      final context = _tabKeys[tab]?.currentContext;
                      if (context != null) {
                        Scrollable.ensureVisible(
                          context,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          alignment: 0.5, // 🔥 CENTER
                        );
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: Obx(() {
        if (!controller.selectionMode.value) {
          return const SizedBox();
        }

        final count = controller.selectedIds.length;

        return Container(
          height: 60,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              if (count == 1)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final todo = await controller.getSelectedTodo();

                    if (todo != null) {
                      _showAddEditDialog(todo: todo);
                    }

                    controller.clearSelection();
                  },
                ),

              if (count == 1)
                IconButton(
                  icon: const Icon(Icons.push_pin),
                  onPressed: controller.pinSelected,
                ),

              IconButton(
                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                onPressed: _confirmDeleteSelected,
              ),
            ],
          ),
        );
      }),

      floatingActionButton:FloatingActionButton(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<TodoModel>>(
        stream: TodoFirestoreService.streamTodos(),
        builder: (context, snapshot) {

          // print("DOC COUNT: ${snapshot.data?.length}");
          // print(snapshot.data);

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTodos = snapshot.data!;

          // IMPORTANT SYNC
          controller.todos.assignAll(allTodos);

          return Obx(() {
            List<TodoModel> todoList;

            if (controller.selectedCategory.value == "All") {

              todoList = allTodos;

            }
            else if (controller.selectedCategory.value == "Starred") {

              todoList = allTodos.where((e) => e.isStarred ?? false).toList();

            }
            else if (controller.selectedCategory.value == "Pending") {

              todoList = allTodos.where((e) => !(e.isDone ?? false)).toList();

            }
            else if (controller.selectedCategory.value == "Completed") {

              todoList = allTodos.where((e) => (e.isDone ?? false)).toList();

            }
            else {

              // custom categories
              todoList = allTodos
                  .where((e) => e.category == controller.selectedCategory.value)
                  .toList();

            }

            todoList.sort((a, b) {
              if ((a.isStarred ?? false) && !(b.isStarred ?? false)) return -1;
              if (!(a.isStarred ?? false) && (b.isStarred ?? false)) return 1;

              switch (controller.selectedSort.value) {
                case SortOption.date:
                  return a.dateTime!.compareTo(b.dateTime!);

                case SortOption.recently:
                  return b.dateTime!.compareTo(a.dateTime!);

                case SortOption.title:
                  return a.title!.toLowerCase().compareTo(
                    b.title!.toLowerCase(),
                  );

                case SortOption.myOrder:
                  return 0;
              }
            });

            final pendingTodos = todoList
                .where((t) => !(t.isDone ?? false))
                .toList();

            final completedTodos = todoList
                .where((t) => (t.isDone ?? false))
                .toList();

            return Column(
              children: [
                Obx(
                      () => AppBar(
                    elevation: 0,
                    backgroundColor:Theme.of(context).colorScheme.surface,

                    leading: controller.selectionMode.value
                        ? IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: controller.clearSelection, // cancel selection
                    )
                        : null, // no leading button when not in selection mode

                    title: controller.selectionMode.value
                        ? Text(
                      "${controller.selectedIds.length} selected",
                      style: TextStyle(color:Theme.of(context).colorScheme.onSurface),
                    )
                        : Text(
                      "Tasks",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),

                    centerTitle: true,

                    actions: [
                      if (controller.selectionMode.value)
                        IconButton(
                          icon: Icon(
                            Icons.select_all,
                            color:Theme.of(context).colorScheme.onSurface
                          ),
                          onPressed: () {
                            final ids = todoList.map((e) => e.id!).toList();
                            controller.toggleSelectAll(ids);
                          },
                        )
                      else
                        InkWell(
                          onTap: () => Get.to(() => ProfilePage()),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Obx(() {
                              final photo = profileController.photoUrl.value;
                              return Hero(
                                tag: "profile_avatar",
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: ClipOval(
                                    child: photo.isEmpty
                                        ? Icon(
                                      Icons.person,
                                      size: 24,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    )
                                        : CachedNetworkImage(
                                      imageUrl: photo,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (c, url) =>
                                      const CircularProgressIndicator(strokeWidth: 2),
                                      errorWidget: (c, url, e) =>
                                      const Icon(Icons.person),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),

                _tabs(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton<SortOption>(
                        icon: const Icon(Icons.sort),
                        onSelected: (value) {
                          controller.selectedSort.value = value;
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: SortOption.date,
                            child: Text("Sort by Date"),
                          ),
                          PopupMenuItem(
                            value: SortOption.recently,
                            child: Text("Recently "),
                          ),
                          PopupMenuItem(
                            value: SortOption.title,
                            child: Text("Sort by Title"),
                          ),
                          PopupMenuItem(
                            value: SortOption.myOrder,
                            child: Text("My Order"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: todoList.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Lottie.asset(
                          'assets/animations/ghosty.json',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "No Tasks Yet",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                       // const SizedBox(height: 6),

                        Text(
                          "Tap + to add a task",
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 150),
                    itemCount: pendingTodos.length +
                        completedTodos.length +
                        (completedTodos.isNotEmpty ? 1 : 0),
                    itemBuilder: (_, i) {

                      if (i == pendingTodos.length &&
                          completedTodos.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            children: [

                              Expanded(
                                child: Divider(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),

                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "Completed",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: Divider(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final todo = i < pendingTodos.length
                          ? pendingTodos[i]
                          : completedTodos[i - pendingTodos.length - 1];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,

                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),

                          color: (todo.isDone ?? false)
                              ? theme.colorScheme.primaryContainer
                              .withOpacity(.35)
                              : theme.colorScheme.surface,

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],

                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: .6,
                          ),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),

                          onLongPress: () {
                            controller.startSelection(todo.id!);
                          },

                          leading: Obx(() {

                            final selected =
                            controller.selectedIds.contains(todo.id);

                            if (controller.selectionMode.value) {

                              return AnimatedSwitcher(
                                duration:
                                const Duration(milliseconds: 200),

                                child: Checkbox(
                                  key: ValueKey(selected),
                                  value: selected,
                                  onChanged: (_) {
                                    controller.toggleSelection(todo.id!);
                                  },
                                ),
                              );
                            }

                            return GestureDetector(
                              onTap: () {
                                TodoFirestoreService.toggleTodo(
                                  todo.id!,
                                  todo.isDone ?? false,
                                );
                              },
                              child: AnimatedSwitcher(
                                duration:
                                const Duration(milliseconds: 300),

                                child: Icon(
                                  todo.isDone ?? false
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  key: ValueKey(todo.isDone),
                                  color: todo.isDone ?? false
                                      ? Colors.green
                                      : theme.colorScheme.onSurfaceVariant,
                                  size: 26,
                                ),
                              ),
                            );
                          }),

                          title: Text(
                            todo.title ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: (todo.isDone ?? false)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),

                          subtitle: Row(
                            children: [

                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                DateFormat('dd MMM • hh:mm a')
                                    .format(todo.dateTime ??
                                    DateTime.now()),
                              ),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              IconButton(
                                icon: Icon(
                                  todo.isStarred ?? false
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: todo.isStarred ?? false
                                      ? Colors.amber
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  TodoFirestoreService.toggleStar(
                                    todo.id!,
                                    todo.isStarred ?? false,
                                  );
                                },
                              ),

                              PopupMenuButton<String>(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),

                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showAddEditDialog(todo: todo);
                                  }
                                  if (value == 'delete') {
                                    _confirmDelete(todo);
                                  }
                                },

                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 10),
                                        Text("Edit"),
                                      ],
                                    ),
                                  ),

                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            color: Colors.red),
                                        SizedBox(width: 10),
                                        Text("Delete"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          });
        },
      ),
    );
  }
}
