// lib/models/password_entry.dart
import 'package:uuid/uuid.dart';

class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PasswordEntry({
    String? id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'],
      title: json['title'],
      username: json['username'],
      password: json['password'],
      url: json['url'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PasswordEntry copyWith({
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
  }) {
    return PasswordEntry(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}