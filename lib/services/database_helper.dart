import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Database name change kiya hai taaki naya schema fresh apply ho
    _database = await _initDB('anape_strict_v6.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. User Management Table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    // 2. Practice History Table
    await db.execute('''
      CREATE TABLE practice_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT,
        accuracy REAL,
        sentence TEXT, 
        eye_contact_ratio REAL, 
        grammar_error_count INTEGER,
        date TEXT
      )
    ''');

    // 3. Exercise Sentences Table
    await db.execute('''
      CREATE TABLE sentences(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sentence_text TEXT,
        difficulty TEXT
      )
    ''');

    // 4. Grammar Engine Rules Table (Strict Chart)
    await db.execute('''
      CREATE TABLE grammar_rules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pattern TEXT,
        replacement TEXT,
        feedback_header TEXT,
        feedback_description TEXT,
        severity_level TEXT
      )
    ''');

    await _seedGrammarLogic(db);
    await _seedSentences(db);
  }

  // --- SEEDING DATA ---

  Future<void> _seedGrammarLogic(Database db) async {
    List<Map<String, String>> rules = [
      {
        'pattern': r'\b(hay|re|kaisa|hai|yaar|kya|bolte|chal|be|tu|apna|naam)\b',
        'replacement': 'Formal English',
        'feedback_header': 'Non-English Slang',
        'feedback_description': 'Professional interviews require English. Avoid Hinglish slangs.',
        'severity_level': 'Critical'
      },
      {
        'pattern': r'\b(i is|he am|she am|they is|we is|you is)\b',
        'replacement': 'Correct Pairing',
        'feedback_header': 'Subject-Verb Mismatch',
        'feedback_description': 'Incorrect auxiliary verb pairing with the subject.',
        'severity_level': 'High'
      },
      {
        'pattern': r'\b(umm|uhh|actually|basically|like like)\b',
        'replacement': '[Pause]',
        'feedback_header': 'Filler Overuse',
        'feedback_description': 'Try to minimize filler words to sound more confident.',
        'severity_level': 'Low'
      }
    ];
    for (var rule in rules) {
      await db.insert('grammar_rules', rule);
    }
  }

  Future<void> _seedSentences(Database db) async {
    await db.insert('sentences', {'sentence_text': 'Artificial Intelligence is revolutionizing modern education.', 'difficulty': 'Hard'});
    await db.insert('sentences', {'sentence_text': 'Consistent practice is the key to mastering any skill.', 'difficulty': 'Easy'});
    await db.insert('sentences', {'sentence_text': 'Could you please introduce yourself and your background?', 'difficulty': 'Medium'});
  }

  // --- CORE FUNCTIONS ---

  // User Registration
  Future<int> registerUser(String name, String email, String password) async {
    final db = await instance.database;
    return await db.insert('users', {'name': name, 'email': email, 'password': password});
  }

  // User Login
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await instance.database;
    final res = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return res.isNotEmpty ? res.first : null;
  }

  // Get Stats for Dashboard
  Future<Map<String, dynamic>> getUserStats(String email) async {
    final db = await instance.database;
    var sessions = await db.rawQuery('SELECT COUNT(*) as count FROM practice_history WHERE user_email = ?', [email]);
    var avg = await db.rawQuery('SELECT AVG(accuracy) as average FROM practice_history WHERE user_email = ?', [email]);
    
    return {
      'sessions': sessions.first['count'] ?? 0,
      'average': (avg.first['average'] as double?)?.toStringAsFixed(1) ?? "0",
    };
  }

  // Save Result (Missing function fix)
  Future<void> savePracticeResult(String email, double accuracy, String sentence) async {
    final db = await instance.database;
    await db.insert('practice_history', {
      'user_email': email,
      'accuracy': accuracy,
      'sentence': sentence,
      'date': DateTime.now().toString(),
    });
  }

  // Get Random Sentence for Practice Page (Error fix)
  Future<String> getRandomSentence() async {
    final db = await instance.database;
    var res = await db.rawQuery('SELECT sentence_text FROM sentences ORDER BY RANDOM() LIMIT 1');
    return res.isNotEmpty ? res.first['sentence_text'] as String : "Tell me something about yourself.";
  }

  // Get All Rules for Grammar Engine
  Future<List<Map<String, dynamic>>> getAllGrammarRules() async {
    final db = await instance.database;
    return await db.query('grammar_rules');
  }
}