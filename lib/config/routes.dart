// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:secure_pass/models/password_entry.dart';
import 'package:secure_pass/screens/auth/login_screen.dart';
import 'package:secure_pass/screens/auth/register_screen.dart';
import 'package:secure_pass/screens/auth/otp_screen.dart';
import 'package:secure_pass/screens/password/password_list_screen.dart';
import 'package:secure_pass/screens/password/password_detail_screen.dart';
import 'package:secure_pass/screens/password/password_add_edit_screen.dart';
import 'package:secure_pass/screens/settings/settings_screen.dart';
import 'package:secure_pass/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp_verification';
  static const String passwordList = '/password_list';
  static const String passwordDetail = '/password_detail';
  static const String passwordAddEdit = '/password_add_edit';
  static const String settings = '/settings';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case otpVerification:
        final email = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => OTPScreen(email: email ?? ''),
        );
      
      case passwordList:
        return MaterialPageRoute(builder: (_) => const PasswordListScreen());
      
      case passwordDetail:
        final password = settings.arguments as PasswordEntry;
        return MaterialPageRoute(
          builder: (_) => PasswordDetailScreen(password: password),
        );
      
      case passwordAddEdit:
        final password = settings.arguments as PasswordEntry?;
        return MaterialPageRoute(
          builder: (_) => PasswordAddEditScreen(password: password),
        );
      
      case AppRoutes.settings:  // Modifié: Ajout d'AppRoutes.
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      default:
        // Si la route n'existe pas, rediriger vers l'écran de connexion
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}