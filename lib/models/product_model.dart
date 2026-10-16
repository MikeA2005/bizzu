class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final String sellerId;
  final bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.sellerId,
    this.isFavorite = false,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    String? sellerId,
    bool? isFavorite,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      sellerId: sellerId ?? this.sellerId,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
