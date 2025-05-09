import 'package:mongo_dart/mongo_dart.dart';

class MongoDBConfig {
  static const String connectionString = 'mongodb+srv://chacon:OtWbeaqHgyEFKVr6@aguaviva.uoyvahn.mongodb.net/?retryWrites=true&w=majority&appName=aguaviva';
  
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