import 'package:flutter/material.dart';
import 'package:bizzu/theme/app_colors.dart';
import 'package:bizzu/models/category_model.dart';
import 'package:bizzu/models/product_model.dart';
import 'package:bizzu/widgets/custom_app_bar.dart';
import 'package:bizzu/widgets/category_icon.dart';
import 'package:bizzu/widgets/product_card.dart';
import 'package:bizzu/services/product_service.dart';
import 'package:bizzu/services/category_service.dart';
import 'package:bizzu/services/auth_service.dart';
import 'package:bizzu/routes/app_routes.dart';

// Pantalla de consulta: muestra los registros remotos sincronizados en tiempo real.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final int _selectedIndex = 1;
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _onlyFavorites = false;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context); // Regresa a HomeScreen
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.publishProduct);
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.manageProducts);
    }
  }

  Future<void> _confirmSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService().signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.authWrapper,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leadingIcon: Icons.arrow_back,
        leadingOnPressed: () => Navigator.pop(context),
        title: 'BIZZU',
        actions: [
          IconButton(
            tooltip: _onlyFavorites ? 'Ver todos' : 'Ver favoritos',
            icon: Icon(
              _onlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: _onlyFavorites
                  ? AppColors.primary
                  : AppColors.textPrimaryLight,
            ),
            onPressed: () => setState(() => _onlyFavorites = !_onlyFavorites),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: AppColors.textPrimaryLight),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: CategoryService().getCategoriesStream(),
        builder: (context, categorySnapshot) {
          final categories = categorySnapshot.data ?? [];

          return StreamBuilder<List<ProductModel>>(
            stream: ProductService().getProductsStream(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productSnapshot.hasError) {
                return Center(
                  child: Text('Error al sincronizar: ${productSnapshot.error}'),
                );
              }

              // Filtrado local instantáneo sobre los datos sincronizados de Firestore
              var products = productSnapshot.data ?? [];
              if (_selectedCategoryId != null) {
                products = products
                    .where((p) => p.categoryId == _selectedCategoryId)
                    .toList();
              }
              if (_onlyFavorites) {
                products = products.where((p) => p.isFavorite).toList();
              }
              if (_searchQuery.isNotEmpty) {
                products = products
                    .where(
                      (p) => p.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
              }

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'Buscar productos...',
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondaryLight,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceLight,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Categorías',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              if (_selectedCategoryId != null)
                                TextButton(
                                  onPressed: () => setState(
                                    () => _selectedCategoryId = null,
                                  ),
                                  child: const Text('Ver todas'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 24.0),
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final isSelected =
                                    _selectedCategoryId == cat.id;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = isSelected
                                          ? null
                                          : cat.id;
                                    });
                                  },
                                  child: Opacity(
                                    opacity:
                                        _selectedCategoryId == null ||
                                            isSelected
                                        ? 1.0
                                        : 0.45,
                                    child: CategoryIcon(
                                      name: cat.name,
                                      iconData: cat.icon,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _onlyFavorites
                                ? 'Tus Favoritos'
                                : 'Destacados en tu Universidad (${products.length})',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  if (products.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No hay productos registrados con este filtro.',
                          style: TextStyle(color: AppColors.textSecondaryLight),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      sliver: SliverGrid.builder(
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16.0,
                              crossAxisSpacing: 16.0,
                              mainAxisExtent: 172.4,
                            ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            image: product.imageUrl,
                            title: product.name,
                            price: product.price.toStringAsFixed(0),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.productDetail,
                                arguments: product.id,
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        backgroundColor: AppColors.surfaceLight,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Mis Ventas',
          ),
        ],
      ),
    );
  }
}
