import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'package:bizzu/theme/app_theme.dart';
import 'package:bizzu/routes/app_pages.dart';

void main() async {
  // Asegura que los plugins estén disponibles antes de abrir Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la misma conexión de Firebase para Android, iOS y web.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Habilita la caché local de Firestore. Los cambios pendientes se envían
  // automáticamente cuando vuelve la conexión a Internet.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

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
      initialRoute: AppPages.initialRoute,
      routes: AppPages.routes,
      onGenerateRoute: AppPages.onGenerateRoute,
    );
  }
}
