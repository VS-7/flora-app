import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class ProductService implements Service<Product> {
  final Repository<Product> _repository;
  final ProductRepository _productRepository;
  final _uuid = const Uuid();

  ProductService(Repository<Product> repository)
    : _repository = repository,
      _productRepository =
          repository is ProductRepository
              ? repository
              : (repository is SyncAwareRepository<Product>)
              ? (repository.baseRepository as ProductRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo ProductRepository ou SyncAwareRepository<Product>',
              );

  @override
  Future<List<Product>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Product?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Product entity) async {
    final existingProduct = await _repository.getById(entity.id);
    if (existingProduct == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<Product> createProduct({
    required String name,
    required String type,
    String? expirationDate,
    required int quantity,
    required String status,
    String? photoUrl,
    String? barcode,
    required String farmId,
  }) async {
    final product = Product(
      id: _uuid.v4(),
      name: name,
      type: type,
      expirationDate: expirationDate,
      quantity: quantity,
      status: status,
      photoUrl: photoUrl,
      barcode: barcode,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(product);
    return product;
  }

  Future<void> updateProduct({
    required String id,
    String? name,
    String? type,
    String? expirationDate,
    int? quantity,
    String? status,
    String? photoUrl,
    String? barcode,
  }) async {
    final product = await _repository.getById(id);
    if (product != null) {
      final updatedProduct = product.copyWith(
        name: name,
        type: type,
        expirationDate: expirationDate,
        quantity: quantity,
        status: status,
        photoUrl: photoUrl,
        barcode: barcode,
      );
      await _repository.update(updatedProduct);
    }
  }

  Future<List<Product>> getProductsByFarmId(String farmId) async {
    return await _productRepository.getProductsByFarmId(farmId);
  }

  Future<List<Product>> getProductsByType(String type, String farmId) async {
    return await _productRepository.getProductsByType(type, farmId);
  }
}
