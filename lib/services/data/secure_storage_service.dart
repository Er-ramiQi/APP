// lib/services/data/secure_storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_pass/services/security/encryption_service.dart';
import 'package:secure_pass/models/password_entry.dart';
import 'package:logger/logger.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  final EncryptionService _encryptionService;
  final Logger _logger = Logger();
  
  // Clés de stockage
  static const String _masterKeyId = 'master_key';
  static const String _passwordPrefix = 'password_';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  
  SecureStorageService(this._encryptionService);
  
  // Initialisation avec la clé maître dérivée du mot de passe principal
  Future<bool> initialize(String masterPassword) async {
    try {
      await _encryptionService.deriveKey(masterPassword);
      
      // Test d'accès au stockage sécurisé
      await _storage.write(key: 'test_key', value: 'test_value');
      final testValue = await _storage.read(key: 'test_key');
      await _storage.delete(key: 'test_key');
      
      if (testValue != 'test_value') {
        _logger.e('Échec du test de stockage sécurisé');
        return false;
      }
      
      return true;
    } catch (e) {
      _logger.e('Erreur lors de l\'initialisation du stockage sécurisé: $e');
      return false;
    }
  }
  
  // Sauvegarde un mot de passe
  Future<bool> savePassword(PasswordEntry entry) async {
    try {
      final String entryJson = jsonEncode(entry.toJson());
      final String encrypted = _encryptionService.encrypt(entryJson);
      
      await _storage.write(key: _getPasswordKey(entry.id), value: encrypted);
      return true;
    } catch (e) {
      _logger.e('Erreur lors de la sauvegarde du mot de passe: $e');
      return false;
    }
  }
  
  // Récupère un mot de passe
  Future<PasswordEntry?> getPassword(String id) async {
    try {
      final String? encryptedEntry = await _storage.read(key: _getPasswordKey(id));
      
      if (encryptedEntry == null) {
        return null;
      }
      
      final String decrypted = _encryptionService.decrypt(encryptedEntry);
      final Map<String, dynamic> entryMap = jsonDecode(decrypted);
      
      return PasswordEntry.fromJson(entryMap);
    } catch (e) {
      _logger.e('Erreur lors de la récupération du mot de passe: $e');
      return null;
    }
  }
  
  // Récupère tous les mots de passe
  Future<List<PasswordEntry>> getAllPasswords() async {
    try {
      final Map<String, String> allValues = await _storage.readAll();
      final List<PasswordEntry> entries = [];
      
      for (final entry in allValues.entries) {
        if (entry.key.startsWith(_passwordPrefix)) {
          try {
            final String decrypted = _encryptionService.decrypt(entry.value);
            final Map<String, dynamic> entryMap = jsonDecode(decrypted);
            entries.add(PasswordEntry.fromJson(entryMap));
          } catch (e) {
            _logger.w('Impossible de déchiffrer l\'entrée: ${entry.key}');
          }
        }
      }
      
      return entries;
    } catch (e) {
      _logger.e('Erreur lors de la récupération des mots de passe: $e');
      return [];
    }
  }
  
  // Supprime un mot de passe
  Future<bool> deletePassword(String id) async {
    try {
      await _storage.delete(key: _getPasswordKey(id));
      return true;
    } catch (e) {
      _logger.e('Erreur lors de la suppression du mot de passe: $e');
      return false;
    }
  }
  
  // Sauvegarde l'ID utilisateur
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }
  
  // Récupère l'ID utilisateur
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
  
  // Sauvegarde l'email utilisateur
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }
  
  // Récupère l'email utilisateur
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }
  
  // Efface toutes les données
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Génère la clé de stockage pour un mot de passe
  String _getPasswordKey(String id) {
    return '$_passwordPrefix$id';
  }
  
  // Méthodes publiques pour lire/écrire (ajoutées pour l'extension)
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }
  
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }
}