import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/article.dart';

class ArticleDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'articles.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE articles (
            id INTEGER PRIMARY KEY,
            title TEXT,
            author TEXT,
            time INTEGER,
            descendants INTEGER,
            url TEXT,
            kids TEXT,
            isFavorite INTEGER
          )
        ''');
      },
    );
  }

  static Future<void> insertArticle(Article article) async {
    final db = await database;

    await db.insert(
      'articles',
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Article?> getArticle(int id) async {
    final db = await database;
    final result = await db.query('articles', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Article.fromMap(result.first);
    } else {
      return null;
    }
  }

  static Future<List<Article>> getAllArticles() async {
    final db = await database;
    final result = await db.query('articles');
    return result.map((map) => Article.fromMap(map)).toList();
  }

  static Future<void> updateFavorite(int id, bool isFav) async {
    final db = await database;
    await db.update(
      'articles',
      {'isFavorite': isFav ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Article>> getFavorites() async {
    final db = await database;
    final result = await db.query('articles', where: 'isFavorite = 1');
    return result.map((map) => Article.fromMap(map)).toList();
  }

  static Future<void> deleteArticle(int id) async {
    final db = await database;
    await db.delete('articles', where: 'id = ?', whereArgs: [id]);
  }
}
