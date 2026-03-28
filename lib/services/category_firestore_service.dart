import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? get uid => FirebaseAuth.instance.currentUser?.uid;


  static CollectionReference get _categoryRef {
    final userId = uid;

    if (userId == null) {
      throw Exception("User not logged in");
    }

    return _db
        .collection("users")
        .doc(userId)
        .collection("categories");
  }

  /// Add new category
  static Future<void> addCategory(String name) async {
    await _categoryRef.doc(name).set({
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Rename category
  static Future<void> renameCategory(String oldName, String newName) async {
    final doc = _categoryRef.doc(oldName);
    final data = await doc.get();

    if (data.exists) {
      await _categoryRef.doc(newName).set(data.data()!);
      await doc.delete();
    }
  }

  /// Delete category
  static Future<void> deleteCategory(String name) async {
    await _categoryRef.doc(name).delete();
  }

  /// Get all categories once
  static Future<List<String>> getCategories() async {
    final snapshot = await _categoryRef.get();
    return snapshot.docs.map((e) => e.id).toList();
  }

  /// Stream categories
  static Stream<List<String>> streamCategories() {
    return _categoryRef.snapshots().map(
          (snapshot) => snapshot.docs.map((e) => e.id).toList(),
    );
  }
}