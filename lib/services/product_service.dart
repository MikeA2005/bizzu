import 'package:flutter/material.dart';
import 'package:bizzu/models/product_model.dart';

class ProductService extends ChangeNotifier {
  // Singleton pattern, so we can access the same instance of ProductService throughout the app
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  // Product data
  final List<ProductModel> _products = [
    ProductModel(
      id: '1',
      name: 'Pizza Margarita',
      description: 'Deliciosa pizza con salsa de tomate, queso mozzarella y albahaca fresca.',
      price: 20000,
      imageUrl: 'https://images.unsplash.com/photo-1596313535886-1c3190577fc7?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=NHwxMjA3fDA%3D',
      categoryId: '1',
      sellerId: '1',
      isFavorite: false,
    ),
    ProductModel(
      id: '2',
      name: 'Hamburguesa Clásica',
      description: 'Jugosa hamburguesa con carne de res, lechuga, tomate y queso cheddar.',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=699&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=NHwxMjA3fDA%3D',
      categoryId: '2',
      sellerId: '2',
      isFavorite: true,
    ),
  ];

  // Get all products
  List<ProductModel> get products => List.unmodifiable(_products);

  // Get product by ID
  ProductModel getProductById(String id) {
    return _products.firstWhere((p) => p.id == id);
  }

  // Get products by category
  List<ProductModel> getProductsByCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return products;
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  // Add a new product
  void addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required String sellerId,
  }) {
    final newProduct = ProductModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
      sellerId: sellerId,
    );
    _products.insert(0, newProduct);
    notifyListeners();
  }

  // Toggle favorite status of a product
  void toggleFavorite(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final current = _products[index];
      _products[index] = current.copyWith(isFavorite: !current.isFavorite);
      notifyListeners();
    }
  }
}
