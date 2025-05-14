// lib/services/auth/auth_service.dart

import 'package:secure_pass/services/auth/token_service.dart';
import 'package:secure_pass/services/auth/biometric_service.dart';
import 'package:secure_pass/services/network/api_service.dart';
import 'package:secure_pass/services/data/secure_storage_service.dart';
import 'package:secure_pass/models/user.dart';
import 'package:logger/logger.dart';

class AuthService {
  final ApiService _apiService;
  final TokenService _tokenService;
  final BiometricService _biometricService;
  final SecureStorageService _secureStorageService;
  final Logger _logger = Logger();
  
  User? _currentUser;
  bool _isBiometricEnabled = false;
  
  AuthService(
    this._apiService,
    this._tokenService,
    this._biometricService,
    this._secureStorageService,
  );
  
  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await _tokenService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  // Récupérer l'utilisateur actuel
  User? getCurrentUser() {
    return _currentUser;
  }
  
  // Vérifier si la biométrie est activée
  bool isBiometricEnabled() {
    return _isBiometricEnabled;
  }
  
  // Activer/désactiver l'authentification biométrique
  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      bool available = await _biometricService.isBiometricAvailable();
      if (!available) {
        _logger.w('La biométrie n\'est pas disponible sur cet appareil');
        return false;
      }
      
      // Authentifier l'utilisateur pour activer la biométrie
      bool authenticated = await _biometricService.authenticate(
        reason: 'Veuillez vous authentifier pour activer la biométrie',
      );
      
      if (!authenticated) {
        _logger.w('L\'authentification biométrique a échoué');
        return false;
      }
    }
    
    _isBiometricEnabled = enabled;
    
    // Stocker le paramètre de biométrie
    await _secureStorageService.saveBiometricEnabled(enabled);
    
    return true;
  }
  
  // Charger les préférences utilisateur
  Future<void> loadUserPreferences() async {
    final biometricEnabled = await _secureStorageService.getBiometricEnabled();
    _isBiometricEnabled = biometricEnabled ?? false;
  }
  
  // Inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> register(String email, String password) async {
    final result = await _apiService.register(email, password);
    
    if (result['success']) {
      _logger.i('Inscription réussie pour $email');
    } else {
      _logger.w('Échec de l\'inscription pour $email: ${result['message']}');
    }
    
    return result;
  }
  
  // Connexion d'un utilisateur existant
  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _apiService.login(email, password);
    
    if (result['success']) {
      _logger.i('Connexion réussie pour $email');
      
      // Charger les informations de l'utilisateur
      if (result['data'] != null && result['data']['user'] != null) {
        _currentUser = User.fromJson(result['data']['user']);
        await _secureStorageService.saveUserEmail(email);
        
        if (result['data']['user']['id'] != null) {
          await _secureStorageService.saveUserId(result['data']['user']['id']);
        }
      }
      
      // Charger les préférences utilisateur
      await loadUserPreferences();
    } else {
      _logger.w('Échec de la connexion pour $email: ${result['message']}');
    }
    
    return result;
  }
  
  // Vérification du code OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final result = await _apiService.verifyOtp(email, otp);
    
    if (result['success']) {
      _logger.i('Vérification OTP réussie pour $email');
      
      // Charger les informations de l'utilisateur
      if (result['data'] != null && result['data']['user'] != null) {
        _currentUser = User.fromJson(result['data']['user']);
      }
    } else {
      _logger.w('Échec de la vérification OTP pour $email: ${result['message']}');
    }
    
    return result;
  }
  
  // Déconnexion
  Future<void> logout() async {
    await _tokenService.clearTokens();
    _currentUser = null;
    _logger.i('Utilisateur déconnecté');
  }
  
  // Authentification par biométrie
  Future<bool> authenticateWithBiometrics() async {
    if (!_isBiometricEnabled) {
      _logger.w('L\'authentification biométrique n\'est pas activée');
      return false;
    }
    
    return await _biometricService.authenticate();
  }
}

// Implémentation des méthodes pour la biométrie dans SecureStorageService
// au lieu d'utiliser une extension qui ne peut pas déclarer des champs d'instance
extension BiometricStorageExtension on SecureStorageService {
  // Clés de stockage
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  // Sauvegarde le paramètre de biométrie
  Future<void> saveBiometricEnabled(bool enabled) async {
    // Utiliser la méthode write de la classe principale
    await write(key: _biometricEnabledKey, value: enabled.toString());
  }
  
  // Récupère le paramètre de biométrie
  Future<bool?> getBiometricEnabled() async {
    // Utiliser la méthode read de la classe principale
    final value = await read(key: _biometricEnabledKey);
    return value != null ? value.toLowerCase() == 'true' : null;
  }
}

// Assurez-vous que ces méthodes sont présentes dans SecureStorageService:
// Future<String?> read({required String key}) async {
//   return await _storage.read(key: key);
// }
//
// Future<void> write({required String key, required String value}) async {
//   await _storage.write(key: key, value: value);
// }