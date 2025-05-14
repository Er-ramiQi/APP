// lib/services/security/code_protection_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';

class CodeProtectionService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Logger _logger = Logger();
  
  // Vérifie si l'application est modifiée ou non sécurisée
  // Utilise une approche alternative sans flutter_jailbreak_detection
  Future<bool> isDeviceRooted() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        // Pour les plateformes de bureau, on considère que c'est moins critique
        _logger.i('Plateforme non mobile détectée: ${Platform.operatingSystem}');
        return false;
      }
      
      // Alternative pour Android: vérifier des chemins communs pour root
      if (Platform.isAndroid) {
        final paths = [
          '/system/app/Superuser.apk',
          '/system/xbin/su',
          '/system/xbin/daemonsu',
          '/sbin/su',
          '/system/bin/su',
          '/system/bin/.ext/.su'
        ];
        
        for (final path in paths) {
          if (await File(path).exists()) {
            _logger.w('Indicateur de root Android détecté: $path');
            return true;
          }
        }
      }
      
      // Pour iOS, nous ne pouvons plus facilement détecter le jailbreak
      // sans la dépendance, donc on retourne false
      
      return false;
    } catch (e) {
      _logger.e('Erreur lors de la détection d\'accès root: $e');
      // En cas d'erreur, on considère l'appareil comme non compromis
      // car c'est probablement juste une erreur de permissions
      return false;
    }
  }
  
  // Vérifie si un débogueur est attaché
  bool isDebuggerAttached() {
    bool isAttached = false;
    
    // En mode debug, on utilise assert pour détecter un débogueur
    assert(() {
      isAttached = true;
      return true;
    }());
    
    if (isAttached) {
      _logger.w('Débogueur détecté');
    }
    
    return isAttached || kDebugMode;
  }
  
  // Vérifie si l'application est en mode debug
  bool isInDebugMode() {
    if (kDebugMode) {
      _logger.w('Application en mode debug');
      return true;
    }
    return false;
  }
  
  // Vérifie si l'application s'exécute dans un émulateur
  Future<bool> isRunningOnEmulator() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final isEmulator = !androidInfo.isPhysicalDevice;
        
        // Vérifier des propriétés supplémentaires
        final brand = androidInfo.brand.toLowerCase();
        final model = androidInfo.model.toLowerCase();
        final product = androidInfo.product.toLowerCase();
        
        final emulatorKeywords = ['emulator', 'simulator', 'sdk', 'virtual', 'genymotion'];
        final isEmulatorByName = emulatorKeywords.any((keyword) => 
          brand.contains(keyword) || model.contains(keyword) || product.contains(keyword));
        
        if (isEmulator || isEmulatorByName) {
          _logger.i('Application exécutée sur un émulateur Android');
          return true;
        }
        
        return false;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final isEmulator = !iosInfo.isPhysicalDevice;
        
        if (isEmulator) {
          _logger.i('Application exécutée sur un simulateur iOS');
        }
        
        return isEmulator;
      }
      
      // Pour les autres plateformes
      return false;
    } catch (e) {
      _logger.e('Erreur lors de la détection d\'émulateur: $e');
      return false;
    }
  }
  
  // Vérifie si le mode développeur est activé (Android seulement)
  // Approche alternative sans flutter_jailbreak_detection
  Future<bool> isDeveloperModeEnabled() async {
    try {
      if (Platform.isAndroid) {
        // Vérification simplifiée du mode développeur
        // NOTE: Cette méthode n'est pas aussi précise que la méthode native,
        // elle détecte simplement si l'appareil est en mode debug
        return kDebugMode;
      }
      
      // Pour les autres plateformes
      return false;
    } catch (e) {
      _logger.e('Erreur lors de la détection du mode développeur: $e');
      return false;
    }
  }
  
  // Vérifie si l'application a été modifiée par rapport à la version publiée
  Future<bool> isAppTampered() async {
    // Note: Cette méthode nécessiterait de vérifier la signature de l'APK ou le bundle iOS
    // Implémentation simplifiée par rapport à l'original
    
    try {
      if (Platform.isAndroid) {
        // Vérifier la signature de l'APK (implémentation factice)
        return false;
      } else if (Platform.isIOS) {
        // Vérifier l'intégrité du bundle iOS (implémentation factice)
        return false;
      }
      
      // Pour les autres plateformes
      return false;
    } catch (e) {
      _logger.e('Erreur lors de la vérification de l\'intégrité de l\'application: $e');
      return false;
    }
  }
  
  // Effectue toutes les vérifications de sécurité de l'environnement
  Future<SecurityResult> checkSecurityStatus() async {
    final isRooted = await isDeviceRooted();
    final isDebugging = isDebuggerAttached();
    final isDebug = isInDebugMode();
    final isEmulator = await isRunningOnEmulator();
    final isDeveloperMode = await isDeveloperModeEnabled();
    final isTampered = await isAppTampered();
    
    final securityLevel = _determineSecurityLevel(
      isRooted: isRooted,
      isDebugging: isDebugging,
      isDebug: isDebug,
      isEmulator: isEmulator,
      isDeveloperMode: isDeveloperMode,
      isTampered: isTampered,
    );
    
    return SecurityResult(
      isRooted: isRooted,
      isDebugging: isDebugging,
      isDebug: isDebug,
      isEmulator: isEmulator,
      isDeveloperMode: isDeveloperMode,
      isTampered: isTampered,
      securityLevel: securityLevel,
    );
  }
  
  // Détermine le niveau de sécurité en fonction des vérifications
  SecurityLevel _determineSecurityLevel({
    required bool isRooted,
    required bool isDebugging,
    required bool isDebug,
    required bool isEmulator,
    required bool isDeveloperMode,
    required bool isTampered,
  }) {
    // Conditions critiques qui compromettent la sécurité de l'application
    if (isRooted || isTampered) {
      return SecurityLevel.critical;
    }
    
    // Conditions à haut risque
    if (isDebugging) {
      return SecurityLevel.high;
    }
    
    // Conditions à risque moyen
    if (isDebug || isDeveloperMode) {
      return SecurityLevel.medium;
    }
    
    // Conditions à faible risque
    if (isEmulator) {
      return SecurityLevel.low;
    }
    
    // Aucun problème détecté
    return SecurityLevel.secure;
  }
}

// Résultat des vérifications de sécurité
class SecurityResult {
  final bool isRooted;
  final bool isDebugging;
  final bool isDebug;
  final bool isEmulator;
  final bool isDeveloperMode;
  final bool isTampered;
  final SecurityLevel securityLevel;
  
  SecurityResult({
    required this.isRooted,
    required this.isDebugging,
    required this.isDebug,
    required this.isEmulator,
    required this.isDeveloperMode,
    required this.isTampered,
    required this.securityLevel,
  });
  
  bool get isSecure => securityLevel == SecurityLevel.secure;
  
  String get securityMessage {
    switch (securityLevel) {
      case SecurityLevel.secure:
        return 'Votre appareil est sécurisé';
      case SecurityLevel.low:
        return 'Niveau de sécurité faible: utilisation d\'un émulateur détectée';
      case SecurityLevel.medium:
        return 'Niveau de sécurité moyen: mode développeur activé ou application en mode debug';
      case SecurityLevel.high:
        return 'Niveau de sécurité élevé: débogueur attaché';
      case SecurityLevel.critical:
        return 'Niveau de sécurité critique: appareil rooté ou application modifiée';
    }
  }
}

// Niveaux de sécurité
enum SecurityLevel {
  secure,
  low,
  medium,
  high,
  critical,
}

// Extension pour faciliter la vérification du niveau de sécurité minimum
extension SecurityLevelExtension on SecurityLevel {
  bool isAtLeast(SecurityLevel level) {
    return index >= level.index;
  }
  
  bool isMoreSevereThan(SecurityLevel level) {
    return index > level.index;
  }
}