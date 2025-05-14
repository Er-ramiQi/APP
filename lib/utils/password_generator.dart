// lib/utils/password_generator.dart
import 'dart:math';

class PasswordGenerator {
  static const String _upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowerChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numberChars = '0123456789';
  static const String _specialChars = '!@#\$%^&*()_-+=<>?/[]{}|';
  
  /// Génère un mot de passe aléatoire avec les options spécifiées.
  static String generate({
    int length = 16,
    bool useUppercase = true,
    bool useLowercase = true,
    bool useNumbers = true,
    bool useSpecial = true,
  }) {
    // Vérifier les arguments
    if (length < 8) {
      length = 8; // Longueur minimale pour la sécurité
    }
    
    if (!useUppercase && !useLowercase && !useNumbers && !useSpecial) {
      // Si aucune option n'est sélectionnée, utiliser les lettres minuscules par défaut
      useLowercase = true;
    }
    
    // Construire la chaîne de caractères à utiliser
    String chars = '';
    
    if (useUppercase) chars += _upperChars;
    if (useLowercase) chars += _lowerChars;
    if (useNumbers) chars += _numberChars;
    if (useSpecial) chars += _specialChars;
    
    // Générer le mot de passe
    final random = Random.secure();
    final password = StringBuffer();
    
    // S'assurer que le mot de passe contient au moins un caractère de chaque type sélectionné
    if (useUppercase) {
      password.write(_upperChars[random.nextInt(_upperChars.length)]);
    }
    if (useLowercase) {
      password.write(_lowerChars[random.nextInt(_lowerChars.length)]);
    }
    if (useNumbers) {
      password.write(_numberChars[random.nextInt(_numberChars.length)]);
    }
    if (useSpecial) {
      password.write(_specialChars[random.nextInt(_specialChars.length)]);
    }
    
    // Remplir le reste de la longueur avec des caractères aléatoires
    while (password.length < length) {
      password.write(chars[random.nextInt(chars.length)]);
    }
    
    // Mélanger les caractères pour éviter les motifs prévisibles
    final passwordList = password.toString().split('');
    passwordList.shuffle(random);
    
    return passwordList.join('');
  }
  
  /// Vérifie la force d'un mot de passe et renvoie un score de 0 à 100.
  static int checkStrength(String password) {
    if (password.isEmpty) {
      return 0;
    }
    
    int score = 0;
    
    // Longueur du mot de passe (jusqu'à 30 points)
    score += min(password.length, 30);
    
    // Présence de différents types de caractères
    if (password.contains(RegExp(r'[A-Z]'))) score += 10;
    if (password.contains(RegExp(r'[a-z]'))) score += 10;
    if (password.contains(RegExp(r'[0-9]'))) score += 10;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score += 10;
    
    // Variété des caractères
    final uniqueChars = password.split('').toSet();
    score += min(uniqueChars.length, 30);
    
    // Pénalités pour les motifs communs
    if (password.contains(RegExp(r'[a-zA-Z]{3,}'))) score -= 5;
    if (password.contains(RegExp(r'[0-9]{3,}'))) score -= 5;
    if (password.contains(RegExp(r'(.)\1{2,}'))) score -= 5; // Caractères répétés
    
    // Limiter le score entre 0 et 100
    return max(0, min(100, score));
  }
  
  /// Renvoie une description de la force du mot de passe.
  static String getStrengthDescription(int strength) {
    if (strength < 20) {
      return 'Très faible';
    } else if (strength < 40) {
      return 'Faible';
    } else if (strength < 60) {
      return 'Moyen';
    } else if (strength < 80) {
      return 'Fort';
    } else {
      return 'Très fort';
    }
  }
  
  /// Renvoie une couleur pour représenter la force du mot de passe.
  static int getStrengthColor(int strength) {
    if (strength < 20) {
      return 0xFFE53935; // Rouge
    } else if (strength < 40) {
      return 0xFFEF6C00; // Orange foncé
    } else if (strength < 60) {
      return 0xFFFFA000; // Orange
    } else if (strength < 80) {
      return 0xFF7CB342; // Vert clair
    } else {
      return 0xFF388E3C; // Vert
    }
  }
}