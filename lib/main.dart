// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:secure_pass/config/routes.dart';
import 'package:secure_pass/config/themes.dart';
import 'package:secure_pass/screens/splash_screen.dart';
import 'package:secure_pass/services/auth/auth_service.dart';
import 'package:secure_pass/services/auth/biometric_service.dart';
import 'package:secure_pass/services/auth/token_service.dart';
import 'package:secure_pass/services/data/secure_storage_service.dart';
import 'package:secure_pass/services/network/api_service.dart';
import 'package:secure_pass/services/network/certificate_service.dart';
import 'package:secure_pass/services/security/code_protection_service.dart';
import 'package:secure_pass/services/security/encryption_service.dart';

void main() async {
  // Assure que les widgets Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();
  
  // Charge les variables d'environnement
  await dotenv.load(fileName: '.env');
  
  // Initialise les services
  final encryptionService = EncryptionService();
  final secureStorageService = SecureStorageService(encryptionService);
  final biometricService = BiometricService();
  final tokenService = TokenService();
  final certificateService = CertificateService();
  final apiService = ApiService(tokenService, certificateService);
  final authService = AuthService(
    apiService,
    tokenService,
    biometricService,
    secureStorageService,
  );
  final codeProtectionService = CodeProtectionService();
  
  // Vérifie la sécurité de l'environnement
  final securityResult = await codeProtectionService.checkSecurityStatus();
  
  // Lance l'application
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: encryptionService),
        Provider.value(value: secureStorageService),
        Provider.value(value: biometricService),
        Provider.value(value: tokenService),
        Provider.value(value: certificateService),
        Provider.value(value: apiService),
        Provider.value(value: authService),
        Provider.value(value: codeProtectionService),
        Provider.value(value: securityResult),
      ],
      child: const SecurePassApp(),
    ),
  );
}

class SecurePassApp extends StatelessWidget {
  const SecurePassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecurePass',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}