import 'package:cloud_firestore/cloud_firestore.dart';

// firestore에 저장/불러오기 하기 위한 클래스 // class to help save & load from Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> uploadTask(String userId, Map<String, dynamic> taskData) async {
    await _db.collection('tasks').add({
      'userId': userId,
      ...taskData
    });
  }
}