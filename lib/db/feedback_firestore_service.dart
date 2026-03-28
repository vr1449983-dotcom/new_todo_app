import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackFirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collection = "feedback";

  static Future<void> addFeedback({
    required String uid,
    required String name,
    required String email,
    required String message,
    String? phone,
  }) async {
    await _db.collection(collection).add({
      "uid": uid,
      "name": name,
      "email": email,
      "phone": phone ?? "",
      "message": message,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Map<String, dynamic>>> streamFeedbacks({String? uid}) {
    Query<Map<String, dynamic>> query =
    _db.collection(collection).orderBy("createdAt", descending: true);

    if (uid != null && uid.isNotEmpty) {
      query = query.where("uid", isEqualTo: uid);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          ...data,
        };
      }).toList();
    });
  }
}