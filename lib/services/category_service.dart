import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bizzu/models/category_model.dart';

// Servicio que lee y crea las categorías almacenadas en Firestore.
class CategoryService {
  // Singleton pattern, igual a tu implementación original
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  // Referencia a la colección 'categories' en Cloud Firestore
  final CollectionReference _categoriesRef = FirebaseFirestore.instance
      .collection('categories');

  /// Escucha en tiempo real las categorías almacenadas en Firestore
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _categoriesRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Obtiene la lista de categorías una sola vez (útil para formularios/dropdowns)
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _categoriesRef.orderBy('name').get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  /// Crea las 5 categorías iniciales en Firestore solo si la colección está vacía
  Future<void> seedInitialCategories() async {
    final snapshot = await _categoriesRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      final defaultCategories = [
        CategoryModel(id: '1', name: 'Comida', iconKey: 'fastfood'),
        CategoryModel(id: '2', name: 'Libros', iconKey: 'book'),
        CategoryModel(id: '3', name: 'Tecnología', iconKey: 'computer'),
        CategoryModel(id: '4', name: 'Entretenimiento', iconKey: 'movie'),
        CategoryModel(id: '5', name: 'Ropa', iconKey: 'shopping_bag'),
      ];

      final batch = FirebaseFirestore.instance.batch();
      for (final category in defaultCategories) {
        // Usamos .doc(category.id) para conservar tus IDs '1', '2', '3', '4', '5'
        final docRef = _categoriesRef.doc(category.id);
        batch.set(docRef, category.toMap());
      }
      await batch.commit();
    }
  }
}
