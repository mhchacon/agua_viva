import 'package:mongo_dart/mongo_dart.dart';
import 'package:agua_viva/config/mongodb_config.dart';
import 'package:agua_viva/models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserService {
  static const String collectionName = 'users';

  // Função para criar um novo usuário
  static Future<User> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    // Verificar se o email já existe
    final existingUser = await collection.findOne(where.eq('email', email));
    if (existingUser != null) {
      throw Exception('Email já cadastrado');
    }

    // Hash da senha
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final user = User(
      id: ObjectId(),
      name: name,
      email: email,
      password: hashedPassword,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await collection.insert(user.toMap());
    return user;
  }

  // Função para autenticar usuário
  static Future<User?> authenticateUser(String email, String password) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final hashedPassword = sha256.convert(utf8.encode(password)).toString();
    
    final userMap = await collection.findOne(
      where.eq('email', email).eq('password', hashedPassword)
    );

    if (userMap == null) return null;
    return User.fromMap(userMap);
  }

  // Função para buscar usuário por ID
  static Future<User?> getUserById(ObjectId id) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final userMap = await collection.findOne(where.id(id));
    if (userMap == null) return null;
    return User.fromMap(userMap);
  }

  // Função para atualizar usuário
  static Future<void> updateUser(User user) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    await collection.update(
      where.id(user.id),
      user.toMap(),
    );
  }

  // Função para deletar usuário
  static Future<void> deleteUser(ObjectId id) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    await collection.remove(where.id(id));
  }

  // Função para listar todos os usuários
  static Future<List<User>> getAllUsers() async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final users = await collection.find().toList();
    return users.map((userMap) => User.fromMap(userMap)).toList();
  }

  // Função para listar usuários por papel
  static Future<List<User>> getUsersByRole(String role) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final users = await collection.find(where.eq('role', role)).toList();
    return users.map((userMap) => User.fromMap(userMap)).toList();
  }
} 