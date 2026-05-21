import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductRepository {
  final FirestoreService _service = FirestoreService();

  Future<List<Product>> loadProducts() {
    return _service.fetchProducts();
  }
}
