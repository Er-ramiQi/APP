// lib/screens/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_pass/services/auth/auth_service.dart';
import 'package:secure_pass/utils/validators.dart';
import 'package:secure_pass/widgets/custom_button.dart';
import 'package:secure_pass/widgets/secure_field.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  
  const OTPScreen({super.key, required this.email});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  
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
    _otpController.dispose();
    super.dispose();
  }
  
  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final result = await _authService.verifyOtp(
      widget.email,
      _otpController.text.trim(),
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (result['success']) {
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
        title: const Text('Vérification OTP'),
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
                  Icons.security,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                // Titre
                const Text(
                  'Vérification en deux étapes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Message d'information
                Text(
                  'Un code de vérification a été envoyé à ${widget.email}. Veuillez l\'entrer ci-dessous.',
                  style: const TextStyle(
                    fontSize: 16,
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
                // Champ OTP
                SecureField(
                  controller: _otpController,
                  labelText: 'Code OTP',
                  hintText: 'Entrez le code à 6 chiffres',
                  keyboardType: TextInputType.number,
                  validator: Validators.validateOtp,
                  prefixIcon: const Icon(Icons.pin),
                ),
                const SizedBox(height: 24),
                // Bouton de vérification
                CustomButton(
                  text: 'Vérifier',
                  onPressed: _isLoading ? null : _verifyOTP,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                // Lien pour renvoyer le code
                TextButton(
                  onPressed: () {
                    // Afficher un message à l'utilisateur
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Un nouveau code a été envoyé à votre adresse email'),
                      ),
                    );
                  },
                  child: const Text('Renvoyer le code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}