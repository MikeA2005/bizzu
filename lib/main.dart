import 'package:bizzu/screens/catalog_screen.dart';
import 'package:bizzu/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BIZZU',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const CatalogScreen(),
    );
  }
}
