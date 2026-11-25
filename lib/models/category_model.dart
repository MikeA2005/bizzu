import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Modelo usado por las categorías disponibles para clasificar productos.
class CategoryModel {
  final String id;
  final String name;
  final String iconKey; // Mantenemos tu nombre original

  CategoryModel({required this.id, required this.name, required this.iconKey});

  IconData get icon {
    switch (iconKey) {
      case 'fastfood':
        return Icons.fastfood;
      case 'book':
        return Icons.book;
      case 'computer':
        return Icons.computer;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? 'Sin categoría',
      iconKey: data['iconKey'] ?? 'category',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconKey': iconKey};
  }
}
