// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_pass/main.dart';  // Modifié pour utiliser le bon nom de package

void main() {
  testWidgets('Smoke test - Verify app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SecurePassApp());  // Utilisez le bon nom de la classe principale

    // Vérifiez que l'application démarre sans erreur
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}