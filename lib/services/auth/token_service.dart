// lib/services/auth/token_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
  
  final Logger _logger = Logger();
  
  // Clés de stockage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Sauvegarde le jeton d'accès
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    _logger.d('Jeton d\'accès sauvegardé');
  }
  
  // Récupère le jeton d'accès
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    
    if (token != null) {
      // Vérifie si le jeton est expiré
      if (isTokenExpired(token)) {
        _logger.w('Le jeton d\'accès est expiré');
        return null;
      }
    }
    
    return token;
  }
  
  // Sauvegarde le jeton de rafraîchissement
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
    _logger.d('Jeton de rafraîchissement sauvegardé');
  }
  
  // Récupère le jeton de rafraîchissement
  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _refreshTokenKey);
    
    if (token != null) {
      // Vérifie si le jeton est expiré
      if (isTokenExpired(token)) {
        _logger.w('Le jeton de rafraîchissement est expiré');
        return null;
      }
    }
    
    return token;
  }
  
  // Efface tous les jetons
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    _logger.i('Jetons effacés');
  }
  
  // Vérifie si un jeton est expiré
  bool isTokenExpired(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      // Vérifie si le jeton a une date d'expiration
      if (decodedToken.containsKey('exp')) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
        return DateTime.now().isAfter(expiryDate);
      }
      
      // Si le jeton n'a pas de date d'expiration, on considère qu'il n'est pas expiré
      return false;
    } catch (e) {
      _logger.e('Erreur lors de la vérification de l\'expiration du jeton: $e');
      // En cas d'erreur, on considère que le jeton est expiré
      return true;
    }
  }
  
  // Récupère les informations du jeton d'accès
  Future<Map<String, dynamic>?> getAccessTokenInfo() async {
    final token = await getAccessToken();
    
    if (token == null || token.isEmpty) {
      return null;
    }
    
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      _logger.e('Erreur lors du décodage du jeton: $e');
      return null;
    }
  }
  
  // Récupère l'ID utilisateur à partir du jeton d'accès
  Future<String?> getUserIdFromToken() async {
    final tokenInfo = await getAccessTokenInfo();
    
    if (tokenInfo == null) {
      return null;
    }
    
    return tokenInfo['sub'];
  }
}