import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/todo_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoFirestoreService {

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user's todo collection
  static CollectionReference<Map<String, dynamic>> get _todoRef {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final uid = user.uid;

    return _firestore
        .collection("users")
        .doc(uid)
        .collection("todos");
  }





  /// Insert a new todo
  static Future<void> insertTodo(TodoModel todo) async {
    try {

      final doc = _todoRef.doc();

      await doc.set({
        'id': doc.id,
        'title': todo.title,
        'category': todo.category,
        'isDone': todo.isDone,
        'isStarred': todo.isStarred,
        'isPinned': todo.isPinned,
        'dateTime': todo.dateTime?.toIso8601String(),
        'deletedAt': null,
      });

    } catch (e) {
      print("Insert Todo Error: $e");
    }
  }

  /// Update existing todo
  static Future<void> updateTodo(TodoModel todo) async {
    try {

      await _todoRef.doc(todo.id.toString()).update({
        'title': todo.title,
        'category': todo.category,
        'isDone': todo.isDone,
        'isStarred': todo.isStarred,
        'isPinned': todo.isPinned,
        'dateTime': todo.dateTime?.toIso8601String(),
      });

    } catch (e) {
      print("Update Todo Error: $e");
    }
  }

  /// Toggle DONE
  static Future<void> toggleTodo(String id, bool currentValue) async {
    try {

      await _todoRef.doc(id).update({
        'isDone': !currentValue,
      });

    } catch (e) {
      print("Toggle Todo Error: $e");
    }
  }

  /// Fetch all todos once
  static Future<List<TodoModel>> getTodos() async {
    try {

      final snapshot = await _todoRef
          .orderBy('dateTime')
          .get();

      return snapshot.docs.map((doc) {
        return TodoModel.fromJson(doc.data());
      }).toList();

    } catch (e) {
      print("Fetch Todo Error: $e");
      return [];
    }
  }

  /// Real-time stream
  static Stream<List<TodoModel>> streamTodos() {

    return _todoRef
        .where('deletedAt', isNull: true)
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {
        return TodoModel.fromJson(doc.data());
      }).toList();

    });
  }

  static Stream<List<TodoModel>> streamTrash() {
    return _todoRef
        .where('deletedAt', isNull: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoModel.fromJson(doc.data());
      }).toList();
    });
  }

  /// Delete permanently
  static Future<void> deleteTodo(String id) async {
    try {

      await _todoRef.doc(id).delete();

    } catch (e) {
      print("Delete Todo Error: $e");
    }
  }

  /// Move to trash
  static Future<void> moveToTrash(String id) async {
    try {
      await _todoRef.doc(id).update({
        'deletedAt': FieldValue.serverTimestamp()
      });
    } catch (e) {
      print("Move to Trash Error: $e");
    }
  }

  //Restore todo

  static Future<void> restoreTodo(String id) async {
    try {
      await _todoRef.doc(id).update({
        'deletedAt': null,
      });
    } catch (e) {
      print("Restore Todo Error: $e");
    }
  }

  /// Toggle Pin
  static Future<void> togglePin(String id, bool currentValue) async {

    await _todoRef.doc(id).update({
      'isPinned': !currentValue,
    });

  }

  /// Update order
  static Future<void> updateOrder(String id, int index) async {

    await _todoRef.doc(id).update({
      'orderIndex': index,
    });

  }

  /// Toggle Star
  static Future<void> toggleStar(String id, bool currentValue) async {
    try {

      await _todoRef.doc(id).update({
        'isStarred': !currentValue,
      });

    } catch (e) {
      print("Toggle Star Error: $e");
    }
  }

  //Auto delete
  static Future<void> autoDeleteOldTrash() async {

    final snapshot = await _todoRef
        .where('deletedAt', isNull: false)
        .get();

    for (var doc in snapshot.docs) {

      final deletedAt = doc['deletedAt'] as Timestamp;

      final deletedDate = deletedAt.toDate();

      final difference = DateTime.now().difference(deletedDate).inDays;

      if (difference >= 30) {
        await _todoRef.doc(doc.id).delete();
      }

    }
  }

}