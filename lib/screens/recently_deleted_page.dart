import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../db/todo_firebase_database.dart';
import '../model/todo_model.dart';

class RecentlyDeletedPage extends StatefulWidget {
  const RecentlyDeletedPage({super.key});

  @override
  State<RecentlyDeletedPage> createState() => _RecentlyDeletedPageState();
}

class _RecentlyDeletedPageState extends State<RecentlyDeletedPage> {

  List<String> allTrashIds = [];
  final RxList<String> selectedIds = <String>[].obs;
  final RxBool selectionMode = false.obs;

  void _confirmPermanentDelete() {

    final ids = selectedIds.toList();

    if (ids.isEmpty) return;

    Get.dialog(
      AlertDialog(
        title: const Text("Delete Permanently"),
        content: Text(
          "Are you sure you want to permanently delete ${ids.length} item(s)?",
        ),
        actions: [

          TextButton(
            onPressed: Get.back,
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              Get.back();

              for (var id in ids) {
                await TodoFirestoreService.deleteTodo(id);
              }

              selectedIds.clear();
              selectionMode.value = false;

              Get.snackbar(
                "Deleted",
                "${ids.length} task(s) deleted permanently",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.black87,
                colorText: Colors.white,
              );
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  void toggleSelection(String id) {

    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }

    if (selectedIds.isEmpty) {
      selectionMode.value = false;
    }
  }

  void selectAll(List<String> ids) {

    if (selectedIds.length == ids.length) {
      selectedIds.clear();
      selectionMode.value = false;
    } else {
      selectedIds.assignAll(ids);
      selectionMode.value = true;
    }
  }

  String remainingDays(DateTime deletedDate) {

    final diff = DateTime.now().difference(deletedDate).inDays;
    final remain = 30 - diff;

    if (remain <= 0) return "Deleting soon";

    return "$remain days remaining";
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(

      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(

        elevation: 0,
        centerTitle: true,

        leading: Obx(() {

          if (selectionMode.value) {
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                selectedIds.clear();
                selectionMode.value = false;
              },
            );
          }

          return const BackButton();
        }),

        title: Obx(() => selectionMode.value
            ? Text("${selectedIds.length} selected")
            : const Text("Recently Deleted")),

        actions: [
          Obx(() {
            if (!selectionMode.value) return const SizedBox();

            final allSelected = selectedIds.length == allTrashIds.length;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: allSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    selectAll(allTrashIds);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),

                          child: Icon(
                            allSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            key: ValueKey(allSelected),
                            size: 20,
                            color: allSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          allSelected ? "Unselect" : "Select All",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: allSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),

      /// BOTTOM ACTION BAR
      bottomNavigationBar: Obx(() {

        if (!selectionMode.value) return const SizedBox();

        return Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 30),

          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(.08),
              )
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              ElevatedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text("Restore"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {

                  for (var id in selectedIds) {
                    await TodoFirestoreService.restoreTodo(id);
                  }

                  selectedIds.clear();
                  selectionMode.value = false;
                },
              ),

              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text("Delete"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: _confirmPermanentDelete,
              )
            ],
          ),
        );
      }),

      /// LIST
      body: StreamBuilder<List<TodoModel>>(

        stream: TodoFirestoreService.streamTrash(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final todos = snapshot.data!;
          allTrashIds = todos.map((e) => e.id!).toList();

          if (todos.isEmpty) {

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.delete_outline,
                    size: 60,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Trash is empty",
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(

            padding: const EdgeInsets.symmetric(vertical: 12),

            itemCount: todos.length,

            itemBuilder: (_, i) {

              final todo = todos[i];

              return Obx(() {

                final selected = selectedIds.contains(todo.id);

                return Card(

                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),

                  elevation: 1,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: ListTile(

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),

                    onLongPress: () {
                      selectionMode.value = true;
                      toggleSelection(todo.id!);
                    },

                    onTap: () {

                      if (selectionMode.value) {
                        toggleSelection(todo.id!);
                      }
                    },

                    leading: selectionMode.value
                        ? Checkbox(
                        value: selected,
                        onChanged: (_) {
                          toggleSelection(todo.id!);
                        })
                        : Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),

                    title: Text(
                      todo.title ?? "",
                      style: theme.textTheme.titleMedium,
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 4),

                        if (todo.deletedAt != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .errorContainer
                                  .withOpacity(.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Icon(
                                  Icons.delete_outline,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.error,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  remainingDays(todo.deletedAt!),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (todo.deletedAt != null)
                          Text(
                            "Deleted on ${DateFormat('dd MMM yyyy').format(todo.deletedAt!)}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// RESTORE BUTTON
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.restore_rounded,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            tooltip: "Restore",
                            onPressed: () async {
                              await TodoFirestoreService.restoreTodo(todo.id!);
                            },
                          ),
                        ),

                        const SizedBox(width: 6),

                        /// DELETE BUTTON
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_forever_rounded,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            tooltip: "Delete permanently",
                            onPressed: () {

                              Get.dialog(
                                AlertDialog(
                                  title: const Text("Delete Permanently"),
                                  content: const Text(
                                    "Are you sure you want to permanently delete this task?",
                                  ),
                                  actions: [

                                    TextButton(
                                      onPressed: Get.back,
                                      child: const Text("Cancel"),
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.error,
                                        foregroundColor: theme.colorScheme.onError,
                                      ),
                                      onPressed: () async {

                                        Get.back();

                                        await TodoFirestoreService.deleteTodo(todo.id!);

                                        Get.snackbar(
                                          "Deleted",
                                          "Task deleted permanently",
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      },
                                      child: const Text("Delete"),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          );
        },
      ),
    );
  }
}