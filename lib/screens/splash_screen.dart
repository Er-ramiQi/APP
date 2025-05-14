// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:secure_pass/services/auth/auth_service.dart';
import 'package:secure_pass/services/security/code_protection_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthService _authService;
  late SecurityResult _securityResult;
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context);
    _securityResult = Provider.of<SecurityResult>(context);
  }
  
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Vérifie le niveau de sécurité
    // Modifié: toujours montrer une alerte pour les niveaux High et Critical
    if (_securityResult.securityLevel == SecurityLevel.critical || 
        _securityResult.securityLevel == SecurityLevel.high) {
      _showSecurityAlert();
      return;
    }
    
    // Pour les niveaux Medium, montrer un avertissement mais permet de continuer
    if (_securityResult.securityLevel == SecurityLevel.medium) {
      _showSecurityWarning();
      return;
    }
    
    // Pour les niveaux Secure et Low, continuer normalement
    _proceedToNextScreen();
  }
  
  Future<void> _proceedToNextScreen() async {
    // Vérifie si l'utilisateur est déjà connecté
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (isLoggedIn) {
      // Si l'utilisateur est connecté, rediriger vers l'écran principal
      Navigator.of(context).pushReplacementNamed('/password_list');
    } else {
      // Sinon, rediriger vers l'écran de connexion
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  
  void _showSecurityAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Alerte de Sécurité'),
        content: Text(_securityResult.securityMessage),
        actions: [
          TextButton(
            onPressed: () {
              // Ferme l'application
              Navigator.of(context).pop();
              // En production, on utiliserait une méthode pour quitter l'application
            },
            child: const Text('Quitter'),
          ),
          TextButton(
            onPressed: () {
              // Continue malgré l'alerte (pour le développement uniquement)
              Navigator.of(context).pop();
              _proceedToNextScreen();
            },
            child: const Text('Continuer (Développement)'),
          ),
        ],
      ),
    );
  }
  
  void _showSecurityWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Avertissement de Sécurité'),
        content: Text(
          '${_securityResult.securityMessage}\n\n'
          'L\'application peut fonctionner dans cet environnement, mais certaines fonctionnalités '
          'de sécurité peuvent être limitées.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Ferme l'alerte et continue
              Navigator.of(context).pop();
              _proceedToNextScreen();
            },
            child: const Text('J\'ai compris, continuer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou icône
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            // Titre de l'application
            Text(
              'SecurePass',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Indicateur de chargement
            SpinKitDoubleBounce(
              color: Colors.blue,
              size: 50.0,
            ),
            SizedBox(height: 20),
            // Message de sécurité
            Text(
              'Vérification de la sécurité...',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}