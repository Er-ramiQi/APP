// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_pass/services/auth/auth_service.dart';
import 'package:secure_pass/utils/validators.dart';
import 'package:secure_pass/widgets/custom_button.dart';
import 'package:secure_pass/widgets/secure_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  late AuthService _authService;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context);
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Vérifier que les mots de passe correspondent
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final result = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (result['success']) {
      // Afficher un message de succès
      _showSuccessDialog();
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Inscription réussie'),
        content: Text(
          'Votre compte a été créé avec succès. Un email de vérification a été envoyé à ${_emailController.text.trim()}. Veuillez vérifier votre boîte de réception pour activer votre compte.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Fermer la boîte de dialogue et retourner à l'écran de connexion
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
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
                  'Créer un compte SecurePass',
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
                  hintText: 'Entrez un mot de passe fort',
                  obscureText: true,
                  validator: Validators.validateStrongPassword,
                  prefixIcon: const Icon(Icons.lock),
                ),
                const SizedBox(height: 8),
                // Indications sur le mot de passe
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un caractère spécial.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Champ de confirmation de mot de passe
                SecureField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirmer le mot de passe',
                  hintText: 'Entrez à nouveau votre mot de passe',
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(Icons.lock),
                ),
                const SizedBox(height: 24),
                // Bouton d'inscription
                CustomButton(
                  text: 'S\'inscrire',
                  onPressed: _isLoading ? null : _register,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                // Lien vers la connexion
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Vous avez déjà un compte ? Connectez-vous'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}