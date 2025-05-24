import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Test SQLite')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await dbHelper.insertArticle(
                    "Premier article",
                    "Contenu ici",
                  );
                  print("Article inséré !");
                },
                child: Text("Insérer article"),
              ),
              ElevatedButton(
                onPressed: () async {
                  List<Map<String, dynamic>> articles =
                      await dbHelper.getArticles();
                  print("Articles : $articles");
                },
                child: Text("Afficher articles"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
