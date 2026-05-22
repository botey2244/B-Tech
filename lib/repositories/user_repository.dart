import '../services/firebase_database_service.dart';

class UserRepository {
  final FirebaseDatabaseService _service = FirebaseDatabaseService();

  Future<Map<String, dynamic>> fetchUserProfile(String uid) {
    return _service.getUserProfile(uid);
  }
}
