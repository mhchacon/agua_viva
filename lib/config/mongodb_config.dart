import 'package:mongo_dart/mongo_dart.dart';

class MongoDBConfig {
  static const String connectionString = 'mongodb://localhost:27017/agua_viva';
  
  // Configurações adicionais do MongoDB
  static const int connectionTimeout = 30000; // 30 segundos
  static const int socketTimeout = 30000; // 30 segundos
  static const int maxPoolSize = 100;
  static const int minPoolSize = 10;
  
  // Nomes das coleções
  static const String assessmentsCollection = 'assessments';
  static const String springsCollection = 'springs';
  static const String usersCollection = 'users';
  
  static Db? _db;
  
  static Future<Db> getDatabase() async {
    if (_db == null) {
      _db = await Db.create(connectionString);
      await _db!.open();
    }
    return _db!;
  }
  
  static Future<void> closeConnection() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
} 