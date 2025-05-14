// lib/services/auth/biometric_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:logger/logger.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final Logger _logger = Logger();
  
  // Vérifie si le périphérique prend en charge la biométrie
  Future<bool> isBiometricAvailable() async {
    try {
      // Vérifie si le matériel prend en charge la biométrie
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        return false;
      }
      
      // Vérifie les types de biométrie disponibles
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      _logger.e('Erreur lors de la vérification de la disponibilité biométrique: $e');
      return false;
    }
  }
  
  // Authentifie l'utilisateur via biométrie
  Future<bool> authenticate({String reason = 'Veuillez vous authentifier pour accéder à vos mots de passe'}) async {
    try {
      bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        _logger.w('La biométrie n\'est pas disponible sur cet appareil');
        return false;
      }
      
      bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        _logger.i('Authentification biométrique réussie');
      } else {
        _logger.w('Authentification biométrique échouée');
      }
      
      return authenticated;
    } catch (e) {
      if (e is String) {
        // Gestion des erreurs spécifiques
        if (e == auth_error.notEnrolled) {
          _logger.e('Aucune biométrie n\'est enregistrée sur cet appareil');
        } else if (e == auth_error.lockedOut) {
          _logger.e('Trop de tentatives échouées, biométrie verrouillée');
        } else if (e == auth_error.notAvailable) {
          _logger.e('La biométrie n\'est pas disponible sur cet appareil');
        } else {
          _logger.e('Erreur d\'authentification biométrique: $e');
        }
      } else {
        _logger.e('Erreur d\'authentification biométrique: $e');
      }
      return false;
    }
  }
}