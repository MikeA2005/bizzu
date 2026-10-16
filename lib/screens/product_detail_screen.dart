import 'package:flutter/material.dart';
import 'package:bizzu/theme/app_colors.dart';
import 'package:bizzu/widgets/custom_app_bar.dart';
import 'package:bizzu/services/product_service.dart';
import 'package:bizzu/services/review_service.dart';
import 'package:bizzu/services/user_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ProductService(),
        ReviewService(),
        UserService(),
      ]),
      builder: (context, _) {
        final product = ProductService().getProductById(productId);
        final seller = UserService().getUserById(product.sellerId);
        final averageRating = ReviewService().getAverageRating(productId);

        return Scaffold(
          // Use the CustomAppBar with a leading icon and an action button
          appBar: CustomAppBar(
            leadingIcon: Icons.arrow_back,
            leadingOnPressed: () {
              Navigator.pop(context);
            },
            title: 'BIZZU',
            actions: [
              IconButton(
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                color: product.isFavorite
                    ? AppColors.primary
                    : AppColors.textPrimaryLight,
                onPressed: () {
                  ProductService().toggleFavorite(product.id);
                },
              ),
            ],
          ),

          // Body content of the screen
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image with rounded corners
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image, size: 80),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Product name and average rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.secondary),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                // Product vendor
                Text(
                  'Vendedor: ${seller.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4.0),
                // Product price
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Divider(height: 32),
                // Product description
                Text(
                  'Descripción',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const Divider(height: 32),
                const Text(
                  'Entrega en campus',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                // Delivery schedule
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.access_time,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Horario Disponible',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            seller.deliverySchedules.join('\n'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimaryLight,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                // Contact seller button
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Text(
                        'Contactar al Vendedor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
