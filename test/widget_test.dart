// Prueba mínima del formulario obligatorio de autenticación.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizzu/screens/login_screen.dart';
import 'package:bizzu/theme/app_theme.dart';

void main() {
  testWidgets('La pantalla de inicio muestra correo y contraseña', (
    WidgetTester tester,
  ) async {
    // Se monta solo LoginScreen para no requerir una conexión Firebase en el test.
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
    );

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
