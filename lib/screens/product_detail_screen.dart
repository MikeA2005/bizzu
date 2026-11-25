import 'package:flutter/material.dart';
import 'package:bizzu/theme/app_colors.dart';
import 'package:bizzu/models/product_model.dart';
import 'package:bizzu/models/review_model.dart';
import 'package:bizzu/models/user_model.dart';
import 'package:bizzu/widgets/custom_app_bar.dart';
import 'package:bizzu/services/product_service.dart';
import 'package:bizzu/services/review_service.dart';
import 'package:bizzu/services/user_service.dart';
import 'package:bizzu/services/auth_service.dart';
import 'package:bizzu/widgets/product_image.dart';
import 'package:bizzu/routes/app_routes.dart';

// Pantalla de detalle y eliminación de una publicación seleccionada.
class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  Future<void> _confirmAndDelete(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Estás seguro de eliminar "${product.name}"? Esta acción borrará el registro de la base de datos de forma permanente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ProductService().deleteProduct(product.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Producto eliminado de la base de datos'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('No tienes permiso o ocurrió un error: $e'),
          ),
        );
      }
    }
  }
  void _showAddReviewDialog(BuildContext context) {
    final commentCtrl = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Agregar Reseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1.0;
                  return IconButton(
                    icon: Icon(
                      starValue <= rating ? Icons.star : Icons.star_border,
                      color: AppColors.secondary,
                    ),
                    onPressed: () => setDialogState(() => rating = starValue),
                  );
                }),
              ),
              TextField(
                controller: commentCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu opinión sobre el producto...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () async {
                if (commentCtrl.text.trim().isEmpty) return;
                await ReviewService().addReview(
                  productId: productId,
                  authorId: AuthService().currentUserId,
                  rating: rating,
                  comment: commentCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text(
                'Enviar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService().currentUserId;

    return StreamBuilder<ProductModel?>(
      stream: ProductService().getProductByIdStream(productId),
      builder: (context, productSnap) {
        if (productSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final product = productSnap.data;
        if (product == null) {
          return Scaffold(
            appBar: CustomAppBar(
              leadingIcon: Icons.arrow_back,
              leadingOnPressed: () => Navigator.pop(context),
              title: 'BIZZU',
            ),
            body: const Center(child: Text('Este producto ya no existe.')),
          );
        }

        final isOwner = product.sellerId == currentUserId;

        return StreamBuilder<List<ReviewModel>>(
          stream: ReviewService().getReviewsStreamByProductId(productId),
          builder: (context, reviewSnap) {
            final reviews = reviewSnap.data ?? [];
            final averageRating = ReviewService().calculateAverageRating(
              reviews,
            );

            return Scaffold(
              appBar: CustomAppBar(
                leadingIcon: Icons.arrow_back,
                leadingOnPressed: () => Navigator.pop(context),
                title: 'BIZZU',
                actions: [
                  IconButton(
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    color: product.isFavorite
                        ? AppColors.primary
                        : AppColors.textPrimaryLight,
                    onPressed: () {
                      ProductService().toggleFavorite(
                        product.id,
                        product.isFavorite,
                      );
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 260,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: ProductImage(
                          imageSource: product.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
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
                            const Icon(Icons.star, color: AppColors.secondary),
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
                    FutureBuilder<UserModel>(
                      future: UserService().getUserById(product.sellerId),
                      builder: (context, userSnap) {
                        final seller = userSnap.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vendedor: ${seller?.name ?? 'Cargando...'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '\$${product.price.toStringAsFixed(0)} COP',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Divider(height: 32),
                            const Text(
                              'Descripción',
                              style: TextStyle(
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
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2.0),
                                  child: Icon(
                                    Icons.access_time,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Horario Disponible',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textPrimaryLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        (seller?.deliverySchedules ??
                                                ['Horario a convenir'])
                                            .join('\n'),
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
                          ],
                        );
                      },
                    ),
                    const Divider(height: 32),
                    // Sección de Reseñas en Firestore (Colección 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reseñas (${reviews.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddReviewDialog(context),
                          icon: const Icon(Icons.rate_review, size: 18),
                          label: const Text('Calificar'),
                        ),
                      ],
                    ),
                    if (reviews.isEmpty)
                      const Text(
                        'Aún no hay reseñas para este producto.',
                        style: TextStyle(color: AppColors.textSecondaryLight),
                      )
                    else
                      ...reviews.map(
                        (r) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              child: Text(r.rating.toStringAsFixed(1)),
                            ),
                            title: Text(r.comment),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24.0),
                    // Botones CRUD para el dueño del producto (Editar y Eliminar con confirmación)
                    if (isOwner) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.editProduct,
                                  arguments: product,
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _confirmAndDelete(context, product),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Botón original Contactar al Vendedor
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Solicitud de contacto enviada al vendedor universitario.',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, color: Colors.white),
                          SizedBox(width: 8.0),
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
      },
    );
  }
}
