import 'package:flutter/material.dart';
import 'package:bizzu/models/category_model.dart';

class CategoryService {
  // Singleton pattern, so we can access the same instance of CategoryService throughout the app
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  // Category data
  final List<CategoryModel> _categories = [
    CategoryModel(id: '1', name: 'Comida', icon: Icons.fastfood),
    CategoryModel(id: '2', name: 'Libros', icon: Icons.book),
    CategoryModel(id: '3', name: 'Tecnología', icon: Icons.computer),
    CategoryModel(id: '4', name: 'Entretenimiento', icon: Icons.movie),
    CategoryModel(id: '5', name: 'Ropa', icon: Icons.shopping_bag),
  ];

  // Get the list of categories
  List<CategoryModel> get categories => List.unmodifiable(_categories);
}
