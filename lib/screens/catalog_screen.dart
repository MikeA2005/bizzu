import 'package:bizzu/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:bizzu/theme/app_colors.dart';
import 'package:bizzu/screens/publish_product_screen.dart';
import 'package:bizzu/widgets/custom_app_bar.dart';
import 'package:bizzu/widgets/category_icon.dart';
import 'package:bizzu/widgets/product_card.dart';
import 'package:bizzu/services/product_service.dart';
import 'package:bizzu/services/category_service.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PublishProductScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app bar with a menu icon, title "BIZZU", and a profile icon on the right
      appBar: const CustomAppBar(
        leadingIcon: Icons.menu,
        title: 'BIZZU',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),

      body: ListenableBuilder(
        listenable: Listenable.merge([ProductService()]),
        builder: (context, _) {
          final categories = CategoryService().categories;
          final products = ProductService().products;

          return CustomScrollView(
            slivers: [
              // SliverPadding to add padding around the search bar, categories, and featured products
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
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
                      const Text(
                        'Categorías',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
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
                            return CategoryIcon(
                              name: categories[index].name,
                              iconData: categories[index].icon,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Destacados en tu Universidad',
                        style: TextStyle(
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

              // sliver grid to display the featured products in a 2-column layout
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                sliver: SliverGrid.builder(
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      price: product.price.toString(),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(productId: product.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        backgroundColor: AppColors.surfaceLight,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}
