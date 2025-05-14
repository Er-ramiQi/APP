// lib/services/network/api_service.dart
import 'package:dio/dio.dart';
import 'package:secure_pass/services/auth/token_service.dart';
import 'package:secure_pass/services/network/certificate_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class ApiService {
  late Dio _dio;
  final TokenService _tokenService;
  final CertificateService _certificateService;
  final Logger _logger = Logger();
  
  // URLs d'API
  late final String _baseUrl;
  static const String _loginEndpoint = '/auth/login';
  static const String _registerEndpoint = '/auth/register';
  static const String _verifyOtpEndpoint = '/auth/verify-otp';
  static const String _refreshTokenEndpoint = '/auth/refresh-token';
  static const String _passwordsEndpoint = '/passwords';
  
  ApiService(this._tokenService, this._certificateService) {
    _baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.securepass.local';
    _initDio();
  }
  
  // Initialise Dio avec les intercepteurs et les options
  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );
    
    // Intercepteur d'authentification
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ajouter le jeton d'authentification à l'en-tête
          final token = await _tokenService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Gestion des erreurs 401 (non autorisé)
          if (error.response?.statusCode == 401) {
            // Tenter de rafraîchir le jeton
            if (await _refreshToken()) {
              // Répéter la requête initiale avec le nouveau jeton
              final token = await _tokenService.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              
              // Créer une nouvelle requête avec les options mises à jour
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  // Vérifie le certificat du serveur avant les requêtes
  Future<bool> _verifyCertificate() async {
    try {
      bool isValid = await _certificateService.verifyCertificateFingerprint();
      if (!isValid) {
        _logger.e('Le certificat du serveur ne correspond pas au fingerprint attendu');
        throw SecurityException('Certificat serveur non valide, possible attaque MITM');
      }
      return true;
    } catch (e) {
      _logger.e('Erreur lors de la vérification du certificat: $e');
      rethrow;
    }
  }
  
  // Tente de rafraîchir le jeton d'authentification
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      
      // Désactiver l'intercepteur pour cette requête
      final originalOptions = _dio.options;
      _dio.options = originalOptions.copyWith(headers: {});
      
      final response = await _dio.post(
        _refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );
      
      // Restaurer les options
      _dio.options = originalOptions;
      
      if (response.statusCode == 200 && response.data['access_token'] != null) {
        await _tokenService.saveAccessToken(response.data['access_token']);
        if (response.data['refresh_token'] != null) {
          await _tokenService.saveRefreshToken(response.data['refresh_token']);
        }
        return true;
      }
      
      // Si le rafraîchissement échoue, déconnexion
      await _tokenService.clearTokens();
      return false;
    } catch (e) {
      _logger.e('Erreur lors du rafraîchissement du jeton: $e');
      await _tokenService.clearTokens();
      return false;
    }
  }
  
  // Méthodes d'API
  
  // Inscription
  Future<Map<String, dynamic>> register(String email, String password) async {
    await _verifyCertificate();
    
    try {
      final response = await _dio.post(
        _registerEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Inscription réussie',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } on DioException catch (e) {
      _logger.e('Erreur Dio lors de l\'inscription: $e');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Erreur de connexion',
      };
    } catch (e) {
      _logger.e('Erreur lors de l\'inscription: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite',
      };
    }
  }
  
  // Connexion
  Future<Map<String, dynamic>> login(String email, String password) async {
    await _verifyCertificate();
    
    try {
      final response = await _dio.post(
        _loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['access_token'] != null) {
          await _tokenService.saveAccessToken(response.data['access_token']);
        }
        if (response.data['refresh_token'] != null) {
          await _tokenService.saveRefreshToken(response.data['refresh_token']);
        }
        
        return {
          'success': true,
          'message': 'Connexion réussie',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Identifiants invalides',
        };
      }
    } on DioException catch (e) {
      _logger.e('Erreur Dio lors de la connexion: $e');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Erreur de connexion',
      };
    } catch (e) {
      _logger.e('Erreur lors de la connexion: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite',
      };
    }
  }
  
  // Vérification OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    await _verifyCertificate();
    
    try {
      final response = await _dio.post(
        _verifyOtpEndpoint,
        data: {
          'email': email,
          'otp': otp,
        },
      );
      
      if (response.statusCode == 200) {
        if (response.data['access_token'] != null) {
          await _tokenService.saveAccessToken(response.data['access_token']);
        }
        
        return {
          'success': true,
          'message': 'Vérification OTP réussie',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Code OTP invalide',
        };
      }
    } on DioException catch (e) {
      _logger.e('Erreur Dio lors de la vérification OTP: $e');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Erreur de connexion',
      };
    } catch (e) {
      _logger.e('Erreur lors de la vérification OTP: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite',
      };
    }
  }
  
  // Obtenir tous les mots de passe
  Future<Map<String, dynamic>> getPasswords() async {
    await _verifyCertificate();
    
    try {
      final response = await _dio.get(_passwordsEndpoint);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur lors de la récupération des mots de passe',
        };
      }
    } on DioException catch (e) {
      _logger.e('Erreur Dio lors de la récupération des mots de passe: $e');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Erreur de connexion',
      };
    } catch (e) {
      _logger.e('Erreur lors de la récupération des mots de passe: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite',
      };
    }
  }
  
  // Enregistrer un mot de passe sur le serveur
  Future<Map<String, dynamic>> savePassword(Map<String, dynamic> passwordData) async {
    await _verifyCertificate();
    
    try {
      final response = await _dio.post(
        _passwordsEndpoint,
        data: passwordData,
      );
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Mot de passe enregistré avec succès',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur lors de l\'enregistrement du mot de passe',
        };
      }
    } on DioException catch (e) {
      _logger.e('Erreur Dio lors de l\'enregistrement du mot de passe: $e');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Erreur de connexion',
      };
    } catch (e) {
      _logger.e('Erreur lors de l\'enregistrement du mot de passe: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite',
      };
    }
  }
  
  // Mettre à jour un mot de passe sur le serveur
  Future<Map<String, dynamic>> updatePassword(String id, Map<String, dynamic> passwordData) async {
    await _verifyCertificate();
    
    try {
      final response = await _dio.put(
        '$_passwordsEndpoint/$id',
        data: passwordData,
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Mot de passe mis à jour avec succès',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur lors de la mise à jour du mot de passe',
        };
      }
    } on DioException catch (e) {
      _logger.e('Erreur Dio lors de la mise à jour du mot de passe: $e');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Erreur de connexion',
      };
    } catch (e) {
      _logger.e('Erreur lors de la mise à jour du mot de passe: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite',
      };
    }
  }
  
  // Supprimer un mot de passe sur le serveur
  Future<Map<String, dynamic>> deletePassword(String id) async {
    await _verifyCertificate();
    
    try {
      final response = await _dio.delete('$_passwordsEndpoint/$id');
      
      if (response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Mot de passe supprimé avec succès',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Erreur lors de la suppression du mot de passe',
        };
      }
    } on DioException catch (e) {
      _logger.e('Erreur Dio lors de la suppression du mot de passe: $e');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Erreur de connexion',
      };
    } catch (e) {
      _logger.e('Erreur lors de la suppression du mot de passe: $e');
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite',
      };
    }
  }
}

class SecurityException implements Exception {
  final String message;
  
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}
