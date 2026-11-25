import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizzu/routes/app_routes.dart';
import 'package:bizzu/models/product_model.dart';
import 'package:bizzu/screens/login_screen.dart';
import 'package:bizzu/screens/home_screen.dart';
import 'package:bizzu/screens/catalog_screen.dart';
import 'package:bizzu/screens/publish_product_screen.dart';
import 'package:bizzu/screens/product_detail_screen.dart';
import 'package:bizzu/screens/edit_product_screen.dart';
import 'package:bizzu/screens/manage_products_screen.dart';

// Mapa de rutas y protección de acceso para las pantallas de la aplicación.
class AppPages {
  AppPages._();

  static const String initialRoute = AppRoutes.authWrapper;

  // Protege las rutas nombradas además del StreamBuilder inicial.
  // De esta forma un usuario no autenticado no puede abrir pantallas por URL.
  static Widget _protected(Widget screen) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) return screen;
        return const LoginScreen();
      },
    );
  }

  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.authWrapper: (context) => StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    ),
    AppRoutes.login: (context) => const LoginScreen(),
    AppRoutes.home: (context) => _protected(const HomeScreen()),
    AppRoutes.catalog: (context) => _protected(const CatalogScreen()),
    AppRoutes.publishProduct: (context) =>
        _protected(const PublishProductScreen()),
    AppRoutes.manageProducts: (context) =>
        _protected(const ManageProductsScreen()),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.productDetail:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) =>
              AppPages._protected(ProductDetailScreen(productId: productId)),
          settings: settings,
        );

      case AppRoutes.editProduct:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) =>
              AppPages._protected(EditProductScreen(product: product)),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
