import 'package:flutter/material.dart';
import '../../domain/models/product_model.dart';
import '../../domain/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService;
  List<Product> _products = [];
  Product? _currentProduct;
  bool _isLoading = false;
  String? _error;

  ProductProvider({required ProductService productService})
    : _productService = productService;

  List<Product> get products => _products;
  Product? get currentProduct => _currentProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProducts => _products.isNotEmpty;

  // Initialize the provider by loading products for a specific farm
  Future<void> initialize(String farmId) async {
    await loadProductsByFarmId(farmId);
  }

  // Load products by farm ID
  Future<void> loadProductsByFarmId(String farmId) async {
    _setLoading(true);
    try {
      _products = await _productService.getProductsByFarmId(farmId);

      // If there are products and no product is currently selected, select the first one
      if (_products.isNotEmpty && _currentProduct == null) {
        _currentProduct = _products.first;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load products by type
  Future<void> loadProductsByType(String type, String farmId) async {
    _setLoading(true);
    try {
      _products = await _productService.getProductsByType(type, farmId);

      // Reset current product if the list changes
      if (_products.isNotEmpty) {
        if (_currentProduct == null ||
            !_products.any((p) => p.id == _currentProduct!.id)) {
          _currentProduct = _products.first;
        }
      } else {
        _currentProduct = null;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load products by type: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Select a product as current
  void selectProduct(String productId) {
    final selectedProduct = _products.firstWhere(
      (product) => product.id == productId,
      orElse: () => _currentProduct!,
    );

    if (selectedProduct.id != _currentProduct?.id) {
      _currentProduct = selectedProduct;
      notifyListeners();
    }
  }

  // Create a new product
  Future<Product?> createProduct({
    required String name,
    required String type,
    String? expirationDate,
    required int quantity,
    required String status,
    String? photoUrl,
    String? barcode,
    required String farmId,
  }) async {
    _setLoading(true);
    try {
      final product = await _productService.createProduct(
        name: name,
        type: type,
        expirationDate: expirationDate,
        quantity: quantity,
        status: status,
        photoUrl: photoUrl,
        barcode: barcode,
        farmId: farmId,
      );

      _products.add(product);

      // If this is the first product, set it as current
      if (_currentProduct == null) {
        _currentProduct = product;
      }

      _clearError();
      notifyListeners();
      return product;
    } catch (e) {
      _setError('Failed to create product: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing product
  Future<bool> updateProduct({
    required String id,
    String? name,
    String? type,
    String? expirationDate,
    int? quantity,
    String? status,
    String? photoUrl,
    String? barcode,
  }) async {
    _setLoading(true);
    try {
      await _productService.updateProduct(
        id: id,
        name: name,
        type: type,
        expirationDate: expirationDate,
        quantity: quantity,
        status: status,
        photoUrl: photoUrl,
        barcode: barcode,
      );

      // Update the local list
      final index = _products.indexWhere((product) => product.id == id);
      if (index != -1) {
        final updatedProduct = await _productService.getById(id);
        if (updatedProduct != null) {
          _products[index] = updatedProduct;

          // If the updated product is the current one, update the reference
          if (_currentProduct?.id == id) {
            _currentProduct = updatedProduct;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update product: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String id) async {
    _setLoading(true);
    try {
      await _productService.delete(id);

      // Remove from the local list
      _products.removeWhere((product) => product.id == id);

      // If the deleted product was the current one, select another if available
      if (_currentProduct?.id == id) {
        _currentProduct = _products.isNotEmpty ? _products.first : null;
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete product: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Utilities to manage state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
