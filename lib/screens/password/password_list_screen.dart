// lib/screens/password/password_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_pass/models/password_entry.dart';
import 'package:secure_pass/services/auth/auth_service.dart';
import 'package:secure_pass/services/auth/biometric_service.dart';
import 'package:secure_pass/services/data/secure_storage_service.dart';
import 'package:secure_pass/widgets/password_tile.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});

  @override
  _PasswordListScreenState createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  late AuthService _authService;
  late BiometricService _biometricService;
  late SecureStorageService _secureStorageService;
  
  List<PasswordEntry> _passwords = [];
  bool _isLoading = true;
  bool _isAuthenticated = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context);
    _biometricService = Provider.of<BiometricService>(context);
    _secureStorageService = Provider.of<SecureStorageService>(context);
    
    _authenticate();
  }
  
  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
    });
    
    // Si la biométrie est activée, demander l'authentification
    if (_authService.isBiometricEnabled()) {
      final authenticated = await _biometricService.authenticate(
        reason: 'Veuillez vous authentifier pour accéder à vos mots de passe',
      );
      
      if (!authenticated) {
        // Si l'authentification échoue, rester sur l'écran de verrouillage
        setState(() {
          _isLoading = false;
          _isAuthenticated = false;
        });
        return;
      }
    }
    
    // Utilisateur authentifié, charger les mots de passe
    setState(() {
      _isAuthenticated = true;
    });
    
    await _loadPasswords();
  }
  
  Future<void> _loadPasswords() async {
    setState(() {
      _isLoading = true;
    });
    
    final passwords = await _secureStorageService.getAllPasswords();
    
    setState(() {
      _passwords = passwords;
      _isLoading = false;
    });
  }
  
  void _addPassword() async {
    final result = await Navigator.of(context).pushNamed('/password_add_edit');
    
    if (result == true) {
      // Recharger les mots de passe si un nouveau a été ajouté
      await _loadPasswords();
    }
  }
  
  void _editPassword(PasswordEntry password) async {
    final result = await Navigator.of(context).pushNamed(
      '/password_add_edit',
      arguments: password,
    );
    
    if (result == true) {
      // Recharger les mots de passe si un a été modifié
      await _loadPasswords();
    }
  }
  
  Future<void> _deletePassword(PasswordEntry password) async {
    // Demander confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer le mot de passe pour ${password.title} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    
    // Supprimer le mot de passe
    final success = await _secureStorageService.deletePassword(password.id);
    
    if (success) {
      // Recharger les mots de passe
      await _loadPasswords();
      
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mot de passe pour ${password.title} supprimé'),
        ),
      );
    } else {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la suppression du mot de passe'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _logout() async {
    // Demander confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    
    // Déconnecter l'utilisateur
    await _authService.logout();
    
    // Rediriger vers l'écran de connexion
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vos mots de passe'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Authentification requise'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Authentification biométrique requise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Réessayer'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _logout,
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos mots de passe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _passwords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_open,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucun mot de passe enregistré',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addPassword,
                    child: const Text('Ajouter un mot de passe'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPasswords,
              child: ListView.builder(
                itemCount: _passwords.length,
                itemBuilder: (context, index) {
                  final password = _passwords[index];
                  return PasswordTile(
                    password: password,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/password_detail',
                        arguments: password,
                      );
                    },
                    onEdit: () => _editPassword(password),
                    onDelete: () => _deletePassword(password),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPassword,
        child: const Icon(Icons.add),
      ),
    );
  }
}