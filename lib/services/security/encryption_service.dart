// lib/services/security/encryption_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart'; // Modifié: supprimé le "as encrypt"
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

class EncryptionService {
  late Key _key;  // Modifié: enlevé encrypt.
  late IV _iv;    // Modifié: enlevé encrypt.
  final Logger _logger = Logger();
  bool _isInitialized = false;
  
  // Dérive une clé de chiffrement à partir du mot de passe maître
  Future<void> deriveKey(String masterPassword) async {
    try {
      // Utilise PBKDF2 pour dériver une clé à partir du mot de passe
      final List<int> salt = utf8.encode('SecurePassSalt');  // En production, utilisez un sel sécurisé stocké
      final pbkdf2 = Pbkdf2(
        iterations: 10000,
        bits: 256,
        hash: sha256,
      );
      
      final Uint8List derivedKey = await pbkdf2.deriveKey(
        password: utf8.encode(masterPassword),
        salt: salt,
      );
      
      _key = Key(derivedKey);  // Modifié: enlevé encrypt.
      
      // Créer un IV à partir des 16 premiers octets du hash du mot de passe
      final hash = sha256.convert(utf8.encode(masterPassword)).bytes;
      _iv = IV(Uint8List.fromList(hash.sublist(0, 16)));  // Modifié: enlevé encrypt.
      
      _isInitialized = true;
      _logger.d('Clé de chiffrement dérivée avec succès');
    } catch (e) {
      _logger.e('Erreur lors de la dérivation de la clé: $e');
      rethrow;
    }
  }
  
  // Chiffre une chaîne
  String encrypt(String plaintext) {
    _checkInitialized();
    
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));  // Modifié: enlevé les encrypt.
    final encrypted = encrypter.encrypt(plaintext, iv: _iv);
    
    return encrypted.base64;
  }
  
  // Déchiffre une chaîne
  String decrypt(String encryptedBase64) {
    _checkInitialized();
    
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));  // Modifié: enlevé les encrypt.
    final decrypted = encrypter.decrypt64(encryptedBase64, iv: _iv);
    
    return decrypted;
  }
  
  // Vérifie si le service est initialisé
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception('EncryptionService non initialisé, appeler deriveKey() d\'abord');
    }
  }
}

class Pbkdf2 {
  final int iterations;
  final int bits;
  final Hash hash;
  
  Pbkdf2({required this.iterations, required this.bits, required this.hash});
  
  Future<Uint8List> deriveKey({
    required List<int> password,
    required List<int> salt,
  }) async {
    Uint8List result = Uint8List(bits ~/ 8);
    
    int blockCount = (bits + 255) ~/ 256;
    
    for (int i = 1; i <= blockCount; i++) {
      Uint8List block = _deriveBlock(password, salt, i);
      int offset = (i - 1) * 32;
      int length = offset + 32 > result.length ? result.length - offset : 32;
      result.setRange(offset, offset + length, block);
    }
    
    return result;
  }
  
  Uint8List _deriveBlock(List<int> password, List<int> salt, int blockIndex) {
    Hmac hmac = Hmac(hash, password);
    List<int> block = List<int>.from(salt);
    
    // Ajoute l'index du bloc au sel
    block.addAll([
      (blockIndex >> 24) & 0xFF,
      (blockIndex >> 16) & 0xFF,
      (blockIndex >> 8) & 0xFF,
      blockIndex & 0xFF,
    ]);
    
    Uint8List u = Uint8List.fromList(hmac.convert(block).bytes);
    Uint8List result = u.sublist(0);
    
    for (int i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    
    return result;
  }
}