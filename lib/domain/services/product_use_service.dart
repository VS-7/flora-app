import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/product_use_model.dart';
import '../../data/repositories/product_use_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class ProductUseService implements Service<ProductUse> {
  final Repository<ProductUse> _repository;
  final ProductUseRepository _productUseRepository;
  final _uuid = const Uuid();

  ProductUseService(Repository<ProductUse> repository)
    : _repository = repository,
      _productUseRepository =
          repository is ProductUseRepository
              ? repository
              : (repository is SyncAwareRepository<ProductUse>)
              ? (repository.baseRepository as ProductUseRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo ProductUseRepository ou SyncAwareRepository<ProductUse>',
              );

  @override
  Future<List<ProductUse>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<ProductUse?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(ProductUse entity) async {
    final existingProductUse = await _repository.getById(entity.id);
    if (existingProductUse == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<ProductUse> createProductUse({
    required DateTime useDate,
    required String description,
    required int usedQuantity,
    required String productId,
    String? harvestId,
    required String farmId,
  }) async {
    final productUse = ProductUse(
      id: _uuid.v4(),
      useDate: useDate,
      description: description,
      usedQuantity: usedQuantity,
      productId: productId,
      harvestId: harvestId,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(productUse);
    return productUse;
  }

  Future<void> updateProductUse({
    required String id,
    DateTime? useDate,
    String? description,
    int? usedQuantity,
    String? harvestId,
  }) async {
    final productUse = await _repository.getById(id);
    if (productUse != null) {
      final updatedProductUse = productUse.copyWith(
        useDate: useDate,
        description: description,
        usedQuantity: usedQuantity,
        harvestId: harvestId,
      );
      await _repository.update(updatedProductUse);
    }
  }

  Future<List<ProductUse>> getProductUsesByProductId(String productId) async {
    return await _productUseRepository.getProductUsesByProductId(productId);
  }

  Future<List<ProductUse>> getProductUsesByHarvestId(String harvestId) async {
    return await _productUseRepository.getProductUsesByHarvestId(harvestId);
  }

  Future<List<ProductUse>> getProductUsesByFarmId(String farmId) async {
    return await _productUseRepository.getProductUsesByFarmId(farmId);
  }
}
