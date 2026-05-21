import '../services/firestore_service.dart';

class UserRepository {
  final FirestoreService _service = FirestoreService();

  Future<Map<String, dynamic>> fetchUserProfile(String uid) {
    return _service.getUserProfile(uid);
  }
}
