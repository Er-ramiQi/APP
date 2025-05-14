// lib/screens/password/password_add_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_pass/models/password_entry.dart';
import 'package:secure_pass/services/data/secure_storage_service.dart';
import 'package:secure_pass/utils/password_generator.dart';
import 'package:secure_pass/utils/validators.dart';
import 'package:secure_pass/widgets/custom_button.dart';
import 'package:secure_pass/widgets/secure_field.dart';

class PasswordAddEditScreen extends StatefulWidget {
  final PasswordEntry? password;
  
  const PasswordAddEditScreen({
    super.key,
    this.password,
  });

  @override
  _PasswordAddEditScreenState createState() => _PasswordAddEditScreenState();
}

class _PasswordAddEditScreenState extends State<PasswordAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  late SecureStorageService _secureStorageService;
  
  bool get _isEditing => widget.password != null;
  
  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      // Remplir les champs avec les valeurs existantes
      _titleController.text = widget.password!.title;
      _usernameController.text = widget.password!.username;
      _passwordController.text = widget.password!.password;
      _urlController.text = widget.password!.url ?? '';
      _notesController.text = widget.password!.notes ?? '';
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _secureStorageService = Provider.of<SecureStorageService>(context);
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final passwordEntry = _isEditing
          ? widget.password!.copyWith(
              title: _titleController.text,
              username: _usernameController.text,
              password: _passwordController.text,
              url: _urlController.text.isNotEmpty ? _urlController.text : null,
              notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            )
          : PasswordEntry(
              title: _titleController.text,
              username: _usernameController.text,
              password: _passwordController.text,
              url: _urlController.text.isNotEmpty ? _urlController.text : null,
              notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            );
      
      final success = await _secureStorageService.savePassword(passwordEntry);
      
      if (success) {
        // Retourner à l'écran précédent avec un résultat positif
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'Une erreur est survenue lors de l\'enregistrement du mot de passe';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue: $e';
        _isLoading = false;
      });
    }
  }
  
  void _generatePassword() {
    // Afficher une boîte de dialogue pour configurer la génération
    showDialog(
      context: context,
      builder: (context) => PasswordGeneratorDialog(
        onGenerated: (password) {
          setState(() {
            _passwordController.text = password;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le mot de passe' : 'Ajouter un mot de passe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              
              // Champ de titre
              SecureField(
                controller: _titleController,
                labelText: 'Titre',
                hintText: 'Ex: Mon email personnel',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.title),
              ),
              const SizedBox(height: 16),
              
              // Champ de nom d'utilisateur
              SecureField(
                controller: _usernameController,
                labelText: 'Nom d\'utilisateur / Email',
                hintText: 'Ex: john.doe@example.com',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom d\'utilisateur';
                  }
                  return null;
                },
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              
              // Champ de mot de passe
              SecureField(
                controller: _passwordController,
                labelText: 'Mot de passe',
                hintText: 'Entrez ou générez un mot de passe',
                obscureText: !_isPasswordVisible,
                validator: Validators.validatePassword,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton pour afficher/masquer le mot de passe
                    IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    // Bouton pour générer un mot de passe
                    IconButton(
                      icon: const Icon(Icons.auto_fix_high, size: 20),
                      onPressed: _generatePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Champ d'URL (optionnel)
              SecureField(
                controller: _urlController,
                labelText: 'URL (optionnel)',
                hintText: 'Ex: https://example.com',
                keyboardType: TextInputType.url,
                prefixIcon: const Icon(Icons.link),
              ),
              const SizedBox(height: 16),
              
              // Champ de notes (optionnel)
              SecureField(
                controller: _notesController,
                labelText: 'Notes (optionnel)',
                hintText: 'Ex: Compte créé le 01/01/2023',
                maxLines: 3,
                prefixIcon: const Icon(Icons.note),
              ),
              const SizedBox(height: 24),
              
              // Bouton de sauvegarde
              CustomButton(
                text: _isEditing ? 'Enregistrer les modifications' : 'Enregistrer',
                onPressed: _isLoading ? null : _savePassword,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordGeneratorDialog extends StatefulWidget {
  final Function(String) onGenerated;
  
  const PasswordGeneratorDialog({
    super.key,
    required this.onGenerated,
  });

  @override
  _PasswordGeneratorDialogState createState() => _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  int _length = 16;
  bool _useUppercase = true;
  bool _useLowercase = true;
  bool _useNumbers = true;
  bool _useSpecial = true;
  
  String _generatedPassword = '';
  
  @override
  void initState() {
    super.initState();
    _generatePassword();
  }
  
  void _generatePassword() {
    setState(() {
      _generatedPassword = PasswordGenerator.generate(
        length: _length,
        useUppercase: _useUppercase,
        useLowercase: _useLowercase,
        useNumbers: _useNumbers,
        useSpecial: _useSpecial,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Générateur de mot de passe'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage du mot de passe généré
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _generatedPassword,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _generatePassword,
                    tooltip: 'Générer à nouveau',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Curseur pour la longueur
            Row(
              children: [
                const Text('Longueur:'),
                Expanded(
                  child: Slider(
                    value: _length.toDouble(),
                    min: 8,
                    max: 32,
                    divisions: 24,
                    onChanged: (value) {
                      setState(() {
                        _length = value.toInt();
                      });
                      _generatePassword();
                    },
                  ),
                ),
                Text('$_length'),
              ],
            ),
            
            // Options de caractères
            CheckboxListTile(
              title: const Text('Majuscules (A-Z)'),
              value: _useUppercase,
              onChanged: (value) {
                setState(() {
                  _useUppercase = value ?? true;
                });
                _generatePassword();
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Minuscules (a-z)'),
              value: _useLowercase,
              onChanged: (value) {
                setState(() {
                  _useLowercase = value ?? true;
                });
                _generatePassword();
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Chiffres (0-9)'),
              value: _useNumbers,
              onChanged: (value) {
                setState(() {
                  _useNumbers = value ?? true;
                });
                _generatePassword();
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
            CheckboxListTile(
              title: const Text('Caractères spéciaux (!@#\$%^&*)'),
              value: _useSpecial,
              onChanged: (value) {
                setState(() {
                  _useSpecial = value ?? true;
                });
                _generatePassword();
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onGenerated(_generatedPassword);
            Navigator.of(context).pop();
          },
          child: const Text('Utiliser'),
        ),
      ],
    );
  }
}