// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_pass/services/auth/auth_service.dart';
import 'package:secure_pass/services/security/encryption_service.dart';
import 'package:secure_pass/services/data/secure_storage_service.dart';
import 'package:secure_pass/utils/validators.dart';
import 'package:secure_pass/widgets/custom_button.dart';
import 'package:secure_pass/widgets/secure_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _showOtpField = false;
  String? _errorMessage;
  
  late AuthService _authService;
  late EncryptionService _encryptionService;
  late SecureStorageService _secureStorageService;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context);
    _encryptionService = Provider.of<EncryptionService>(context);
    _secureStorageService = Provider.of<SecureStorageService>(context);
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    if (_showOtpField) {
      await _verifyOtp();
    } else {
      await _performLogin();
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _performLogin() async {
    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (result['success']) {
      // Si l'OTP est requis
      if (result['data'] != null && result['data']['requires_otp'] == true) {
        setState(() {
          _showOtpField = true;
          _errorMessage = null;
        });
      } else {
        // Initialiser le service de stockage avec le mot de passe
        await _encryptionService.deriveKey(_passwordController.text);
        await _secureStorageService.initialize(_passwordController.text);
        
        // Rediriger vers l'écran principal
        Navigator.of(context).pushReplacementNamed('/password_list');
      }
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }
  
  Future<void> _verifyOtp() async {
    final result = await _authService.verifyOtp(
      _emailController.text.trim(),
      _otpController.text.trim(),
    );
    
    if (result['success']) {
      // Initialiser le service de stockage avec le mot de passe
      await _encryptionService.deriveKey(_passwordController.text);
      await _secureStorageService.initialize(_passwordController.text);
      
      // Rediriger vers l'écran principal
      Navigator.of(context).pushReplacementNamed('/password_list');
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou icône
                const Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                // Titre
                const Text(
                  'SecurePass',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Afficher le message d'erreur s'il y en a un
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_errorMessage != null)
                  const SizedBox(height: 20),
                // Champ d'email
                SecureField(
                  controller: _emailController,
                  labelText: 'Adresse email',
                  hintText: 'Entrez votre adresse email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email),
                ),
                const SizedBox(height: 16),
                // Champ de mot de passe
                SecureField(
                  controller: _passwordController,
                  labelText: 'Mot de passe',
                  hintText: 'Entrez votre mot de passe',
                  obscureText: true,
                  validator: Validators.validatePassword,
                  prefixIcon: const Icon(Icons.lock),
                ),
                const SizedBox(height: 16),
                // Champ OTP (si nécessaire)
                if (_showOtpField) ...[
                  SecureField(
                    controller: _otpController,
                    labelText: 'Code OTP',
                    hintText: 'Entrez le code reçu par email',
                    keyboardType: TextInputType.number,
                    validator: Validators.validateOtp,
                    prefixIcon: const Icon(Icons.security),
                  ),
                  const SizedBox(height: 16),
                ],
                // Bouton de connexion
                CustomButton(
                  text: _showOtpField ? 'Vérifier' : 'Se connecter',
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                // Lien vers l'inscription
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register');
                  },
                  child: const Text('Vous n\'avez pas de compte ? Inscrivez-vous'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}