import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bizzu/models/product_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final CollectionReference _productsRef = FirebaseFirestore.instance
      .collection('products');

  /// Stream en tiempo real de TODOS los productos (sincronización bidireccional)
  Stream<List<ProductModel>> getProductsStream({String? categoryId}) {
    Query query = _productsRef.orderBy('createdAt', descending: true);
    if (categoryId != null && categoryId.isNotEmpty) {
      query = _productsRef
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream de los productos publicados únicamente por el usuario actual (para Gestión)
  Stream<List<ProductModel>> getUserProductsStream(String sellerId) {
    return _productsRef.where('sellerId', isEqualTo: sellerId).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Obtener un producto específico en tiempo real
  Stream<ProductModel?> getProductByIdStream(String id) {
    return _productsRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProductModel.fromFirestore(doc);
    });
  }

  /// CREAR producto en Firestore
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String categoryId,
    required String sellerId,
  }) async {
    final newProduct = ProductModel(
      id: '',
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      categoryId: categoryId,
      sellerId: sellerId,
      isFavorite: false,
      createdAt: DateTime.now(),
    );
    await _productsRef.add(newProduct.toMap());
  }

  /// ACTUALIZAR producto existente en Firestore
  Future<void> updateProduct(ProductModel product) async {
    await _productsRef.doc(product.id).update(product.toMap());
  }

  /// ELIMINAR producto de Firestore
  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }

  /// Alternar favorito en Firestore
  Future<void> toggleFavorite(String productId, bool currentStatus) async {
    await _productsRef.doc(productId).update({'isFavorite': !currentStatus});
  }
}
