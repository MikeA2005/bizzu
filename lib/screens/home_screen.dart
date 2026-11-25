import 'package:bizzu/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:bizzu/theme/app_colors.dart';
import 'package:bizzu/models/user_model.dart';
import 'package:bizzu/models/product_model.dart';
import 'package:bizzu/widgets/custom_app_bar.dart';
import 'package:bizzu/services/auth_service.dart';
import 'package:bizzu/services/user_service.dart';
import 'package:bizzu/services/product_service.dart';
import 'package:bizzu/services/category_service.dart';

// Pantalla de inicio: presenta estadísticas y navega a las funciones principales.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Poblar categorías iniciales en Firestore si aún no existen
    CategoryService().seedInitialCategories();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUserId;

    return Scaffold(
      appBar: CustomAppBar(
        leadingIcon: Icons.storefront,
        title: 'BIZZU',
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: AppColors.textPrimaryLight),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.authWrapper,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel>(
        stream: UserService().getCurrentUserStream(),
        builder: (context, userSnap) {
          final user = userSnap.data;

          return StreamBuilder<List<ProductModel>>(
            stream: ProductService().getProductsStream(),
            builder: (context, productsSnap) {
              final allProducts = productsSnap.data ?? [];
              final myProductsCount = allProducts
                  .where((p) => p.sellerId == uid)
                  .length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta de bienvenida y sincronización activa
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${user?.name ?? 'Estudiante'}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Compra y vende productos dentro de tu campus universitario con sincronización en la nube.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatChip(
                                label: 'En Catálogo',
                                value: '${allProducts.length}',
                              ),
                              const SizedBox(width: 12),
                              _StatChip(
                                label: 'Mis Publicaciones',
                                value: '$myProductsCount',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '¿Qué deseas hacer hoy?',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _MenuCard(
                      icon: Icons.grid_view_rounded,
                      title: 'Explorar Catálogo',
                      subtitle: 'Consulta todos los productos publicados en tiempo real',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.catalog),
                    ),
                    const SizedBox(height: 12),
                    _MenuCard(
                      icon: Icons.add_box_rounded,
                      title: 'Publicar Producto',
                      subtitle: 'Registra un nuevo artículo para vender en la universidad',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.publishProduct,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MenuCard(
                      icon: Icons.manage_accounts_rounded,
                      title: 'Gestionar Mis Publicaciones',
                      subtitle: 'Edita precios, descripciones o elimina tus productos',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.manageProducts,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary,
          child: Icon(icon, color: AppColors.textPrimaryLight),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
