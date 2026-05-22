import '../models/product.dart';
import '../services/firebase_database_service.dart';

class ProductRepository {
  final FirebaseDatabaseService _service = FirebaseDatabaseService();

  Future<List<Product>> loadProducts() {
    return _service.fetchProducts();
  }
}
