// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_pass/services/auth/auth_service.dart';
import 'package:secure_pass/services/auth/biometric_service.dart';
import 'package:secure_pass/services/data/secure_storage_service.dart';
import 'package:secure_pass/services/security/code_protection_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBiometricEnabled = false;
  bool _isLoading = false;
  
  late AuthService _authService;
  late BiometricService _biometricService;
  late CodeProtectionService _codeProtectionService;
  late SecureStorageService _secureStorageService;
  late SecurityResult _securityResult;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authService = Provider.of<AuthService>(context);
    _biometricService = Provider.of<BiometricService>(context);
    _codeProtectionService = Provider.of<CodeProtectionService>(context);
    _secureStorageService = Provider.of<SecureStorageService>(context);
    _securityResult = Provider.of<SecurityResult>(context);
    
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    // Charger les paramètres
    _isBiometricEnabled = _authService.isBiometricEnabled();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _toggleBiometric(bool value) async {
    setState(() {
      _isLoading = true;
    });
    
    final updated = await _authService.setBiometricEnabled(value);
    
    if (updated) {
      setState(() {
        _isBiometricEnabled = value;
      });
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _clearAllData() async {
    // Demander confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes vos données ? Cette action est irréversible.',
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Supprimer tout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    
    // Seconde confirmation
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dernière confirmation'),
        content: const Text(
          'Toutes vos données vont être supprimées. Êtes-vous vraiment sûr ?',
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Confirmer la suppression',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (doubleConfirmed != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Supprimer toutes les données
    await _secureStorageService.clearAll();
    
    // Déconnecter l'utilisateur
    await _authService.logout();
    
    // Rediriger vers l'écran de connexion
    Navigator.of(context).pushReplacementNamed('/login');
  }
  
  Future<void> _checkSecurityStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    // Vérifier l'état de la sécurité
    final securityResult = await _codeProtectionService.checkSecurityStatus();
    
    setState(() {
      _isLoading = false;
    });
    
    // Afficher les résultats
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('État de la sécurité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecurityStatusItem(
              'Appareil rooté/jailbreaké',
              securityResult.isRooted,
              isErrorWhenTrue: true,
            ),
            _buildSecurityStatusItem(
              'Débogueur attaché',
              securityResult.isDebugging,
              isErrorWhenTrue: true,
            ),
            _buildSecurityStatusItem(
              'Mode debug',
              securityResult.isDebug,
              isErrorWhenTrue: true,
            ),
            _buildSecurityStatusItem(
              'Émulateur',
              securityResult.isEmulator,
              isErrorWhenTrue: false,
            ),
            _buildSecurityStatusItem(
              'Mode développeur',
              securityResult.isDeveloperMode,
              isErrorWhenTrue: true,
            ),
            _buildSecurityStatusItem(
              'Application modifiée',
              securityResult.isTampered,
              isErrorWhenTrue: true,
            ),
            const Divider(),
            Row(
              children: [
                const Text(
                  'Niveau de sécurité:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                _buildSecurityLevelChip(securityResult.securityLevel),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSecurityStatusItem(String label, bool value, {required bool isErrorWhenTrue}) {
    final isError = isErrorWhenTrue ? value : false;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: isError ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSecurityLevelChip(SecurityLevel level) {
    Color color;
    String text;
    
    switch (level) {
      case SecurityLevel.secure:
        color = Colors.green;
        text = 'Sécurisé';
        break;
      case SecurityLevel.low:
        color = Colors.blue;
        text = 'Faible';
        break;
      case SecurityLevel.medium:
        color = Colors.orange;
        text = 'Moyen';
        break;
      case SecurityLevel.high:
        color = Colors.deepOrange;
        text = 'Élevé';
        break;
      case SecurityLevel.critical:
        color = Colors.red;
        text = 'Critique';
        break;
    }
    
    return Chip(
      label: Text(text),
      backgroundColor: color.withAlpha(51),
      labelStyle: TextStyle(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section de sécurité
          _buildSectionHeader('Sécurité'),
          Card(
            child: Column(
              children: [
                // Option biométrique
                SwitchListTile(
                  title: const Text('Utiliser la biométrie'),
                  subtitle: const Text('Déverrouiller l\'application avec votre empreinte digitale ou votre visage'),
                  value: _isBiometricEnabled,
                  onChanged: (bool? available) async {
                    if (available != null) {
                      await _toggleBiometric(available);
                    }
                  },
                ),
                
                // Divider
                const Divider(),
                
                // Vérification de la sécurité
                ListTile(
                  title: const Text('Vérifier la sécurité'),
                  subtitle: const Text('Analyser les vulnérabilités de l\'appareil'),
                  trailing: const Icon(Icons.security),
                  onTap: _checkSecurityStatus,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Section des données
          _buildSectionHeader('Données'),
          Card(
            child: Column(
              children: [
                // Suppression des données
                ListTile(
                  title: const Text('Supprimer toutes les données'),
                  subtitle: const Text('Effacer tous les mots de passe et les paramètres'),
                  trailing: const Icon(Icons.delete_forever, color: Colors.red),
                  onTap: _clearAllData,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Section de compte
          _buildSectionHeader('Compte'),
          Card(
            child: Column(
              children: [
                // Informations de compte
                ListTile(
                  title: const Text('Adresse email'),
                  subtitle: FutureBuilder<String?>(
                    future: _secureStorageService.getUserEmail(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Text(snapshot.data!);
                      }
                      return const Text('Chargement...');
                    },
                  ),
                ),
                
                // Divider
                const Divider(),
                
                // Déconnexion
                ListTile(
                  title: const Text('Déconnexion'),
                  trailing: const Icon(Icons.logout),
                  onTap: () async {
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
                    
                    if (confirmed == true) {
                      await _authService.logout();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Section à propos
          _buildSectionHeader('À propos'),
          const Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  title: Text('Développé par'),
                  subtitle: Text('Votre Nom'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}