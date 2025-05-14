// lib/utils/validators.dart
class Validators {
  /// Valide une adresse email.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une adresse email';
    }
    
    // Expression régulière pour la validation d'email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide';
    }
    
    return null;
  }
  
  /// Valide un mot de passe (simple).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    
    return null;
  }
  
  /// Valide un mot de passe (fort).
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une majuscule';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une minuscule';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    
    if (!value.contains(RegExp(r'[!@#\$%\^&\*\(\)_\-+=<>\?/\[\]\{\}\|]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }
    
    return null;
  }
  
  /// Valide un code OTP à 6 chiffres.
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le code OTP';
    }
    
    // Expression régulière pour un code à 6 chiffres
    final otpRegex = RegExp(r'^[0-9]{6}$');
    
    if (!otpRegex.hasMatch(value)) {
      return 'Le code OTP doit contenir 6 chiffres';
    }
    
    return null;
  }
  
  /// Valide une URL.
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL optionnelle
    }
    
    // Expression régulière pour la validation d'URL
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Veuillez entrer une URL valide';
    }
    
    return null;
  }
}