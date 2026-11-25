import 'package:flutter/material.dart';
import 'package:bizzu/theme/app_colors.dart';
import 'package:bizzu/models/product_model.dart';
import 'package:bizzu/widgets/custom_app_bar.dart';
import 'package:bizzu/services/product_service.dart';
import 'package:bizzu/services/auth_service.dart';
import 'package:bizzu/widgets/product_image.dart';
import 'package:bizzu/routes/app_routes.dart';

// Pantalla principal de gestión: administra las publicaciones del usuario actual.
class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  Future<void> _deleteProduct(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Deseas eliminar "${product.name}" de tu inventario?'),
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
      await ProductService().deleteProduct(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Producto eliminado exitosamente'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUserId;

    return Scaffold(
      appBar: CustomAppBar(
        leadingIcon: Icons.arrow_back,
        leadingOnPressed: () => Navigator.pop(context),
        title: 'MIS PUBLICACIONES',
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.publishProduct),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: ProductService().getUserProductsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final myProducts = snapshot.data ?? [];

          if (myProducts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Aún no has publicado productos.\nPresiona "+ Nuevo" para registrar tu primer artículo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: myProducts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = myProducts[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ProductImage(
                      imageSource: item.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('\$${item.price.toStringAsFixed(0)} COP'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.productDetail,
                    arguments: item.id,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.editProduct,
                          arguments: item,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(context, item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
