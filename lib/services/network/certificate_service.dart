// lib/services/network/certificate_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:ssl_pinning_plugin/ssl_pinning_plugin.dart';

class CertificateService {
  // Liste des empreintes SHA-256 fiables
  final List<String> _trustedFingerprints = [];
  final Logger _logger = Logger();
  final Dio _dio = Dio();
  
  CertificateService() {
    _initTrustedFingerprints();
  }
  
  // Initialise la liste des empreintes fiables
  void _initTrustedFingerprints() {
    // Charger les empreintes depuis le fichier .env
    final String? fingerprintString = dotenv.env['TRUSTED_CERTIFICATE_FINGERPRINTS'];
    
    if (fingerprintString != null && fingerprintString.isNotEmpty) {
      _trustedFingerprints.addAll(fingerprintString.split(',').map((f) => f.trim()));
    }
    
    // Ajouter une empreinte de secours codée en dur (uniquement pour les démos, à éviter en production)
    const String backupFingerprint = 'SHA-256:A1:B2:C3:D4:E5:F6:...:XY:Z0'; // Remplacer par une vraie empreinte
    if (!_trustedFingerprints.contains(backupFingerprint)) {
      _trustedFingerprints.add(backupFingerprint);
    }
    
    _logger.d('${_trustedFingerprints.length} empreintes de certificat fiables chargées');
  }
  
  // Vérifie l'empreinte du certificat du serveur avec SSL Pinning
  Future<bool> verifyCertificateFingerprint() async {
    if (_trustedFingerprints.isEmpty) {
      _logger.e('Aucune empreinte de certificat fiable configurée');
      return false;
    }
    
    try {
      final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.securepass.local';
      
      final result = await SslPinningPlugin.check(
        serverURL: baseUrl,
        sha: SHA.SHA256,
        allowedSHAFingerprints: _trustedFingerprints,
        timeout: 60, // timeout en secondes
      );
      
      _logger.i('Vérification du certificat: $result');
      return result == "CONNECTION_SECURE";
    } catch (e) {
      _logger.e('Erreur lors de la vérification du certificat: $e');
      return false;
    }
  }
  
  // Obtient l'empreinte du certificat actuel du serveur (pour le débogage)
  Future<String?> getCurrentCertificateFingerprint() async {
    try {
      final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.securepass.local';
      
      // Méthode alternative pour obtenir l'empreinte
      _logger.i('Obtention de l\'empreinte du certificat pour $baseUrl');
      return "Empreinte à récupérer manuellement - Fonction non disponible";
    } catch (e) {
      _logger.e('Erreur lors de l\'obtention de l\'empreinte du certificat: $e');
      return null;
    }
  }
  
  // Ajoute une nouvelle empreinte à la liste des empreintes fiables
  Future<void> addTrustedFingerprint(String fingerprint) async {
    if (!_trustedFingerprints.contains(fingerprint)) {
      _trustedFingerprints.add(fingerprint);
      _logger.i('Empreinte de certificat ajoutée: $fingerprint');
    }
  }
}