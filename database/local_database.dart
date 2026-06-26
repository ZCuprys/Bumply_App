import 'package:sqflite/sqflite.dart'; //daje dostęp do SQLite we Flutter
import 'package:path/path.dart'; //służy do poprawnego łączenia ścieżek plików (ścieżka do pliku bazy danych)

class LocalDatabase { //cała obsługa bazzy danych, wszystkie metody
  LocalDatabase._privateConstructor(); //pryw żeby nie tworzyć wielu obiektów bazy

  static final LocalDatabase instance = LocalDatabase._privateConstructor(); //jeden punkt dostępowy lokalnej bazy danych

  static Database? _database; //zmienna przechowująca lokalnego połączenia z bazą

  Future<Database> get database async { //baza jest tworzona tylko raz, jeśli istnieje zwraca istniejące połączenie
    if (_database != null) {
      return _database!; //!-wiem że nie null
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async { //fizycznie tworzy albo otwiera bazę
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, 'bumply.db'); //pełna ścieżka do bumply.db

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _createDatabase, //tylko przy pierwszym
    );
  }

  Future<void> _onConfigure(Database db) async { //obsługa kluczy obcych
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDatabase(Database db, int version) async { //tworzenie tabel
    await db.execute(''' 
      CREATE TABLE user_profile ( 
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        login TEXT NOT NULL UNIQUE,
        display_name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    '''); //przechowuje użytkowników aplikacji

    await db.execute('''
      CREATE TABLE symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL
      )
    '''); //przechowuje słownik symptomów

    await db.execute('''
      CREATE TABLE symptom_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        symptom_id INTEGER NOT NULL,
        entry_date TEXT NOT NULL,
        note TEXT,
        intensity INTEGER, 
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profile (id),
        FOREIGN KEY (symptom_id) REFERENCES symptoms (id),
        UNIQUE (user_id, symptom_id, entry_date)
      )
    '''); //konkretny użytkownik, konkretny symptom, konkretnego dnia//

    await db.execute('''
      CREATE TABLE articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    '''); //przechowuje artykuły

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        summary TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profile (id)
      )
    '''); //przechowuje wygenerowane raporty

    await _insertInitialData(db); //dodanie danych start
  }

  Future<void> _insertInitialData(Database db) async { //dodanie symptomów do tabeli
    final symptoms = [
      {'name': 'Nausea', 'category': 'Wellbeing'},
      {'name': 'Headache', 'category': 'Pain'},
      {'name': 'Fatigue', 'category': 'Wellbeing'},
      {'name': 'Back pain', 'category': 'Pain'},
      {'name': 'Heartburn', 'category': 'Digestion'},
      {'name': 'Insomnia', 'category': 'Sleep'},
      {'name': 'Dizziness', 'category': 'Wellbeing'},
      {'name': 'Swelling', 'category': 'Body'},
      {'name': 'Cramps', 'category': 'Pain'},
      {'name': 'Mood swings', 'category': 'Wellbeing'},
    ];

    for (final symptom in symptoms) {
      await db.insert(
        'symptoms',
        symptom,
        conflictAlgorithm: ConflictAlgorithm.ignore, //jeśli istnieje nie dodawaj i nie error
      );
    }

    final now = DateTime.now().toIso8601String();

    final articles = [
      {
        'title': 'Healthy eating during pregnancy',
        'content':
            'During pregnancy, it is important to eat regular meals, stay hydrated and choose foods rich in vitamins and minerals.',
        'category': 'Health',
        'created_at': now,
      },
      {
        'title': 'Rest and sleep',
        'content':
            'Getting enough sleep and rest helps the body cope better with the changes that occur during pregnancy.',
        'category': 'Wellbeing',
        'created_at': now,
      },
      {
        'title': 'When to contact a doctor',
        'content':
            'In case of severe pain, bleeding, fainting, or sudden worsening of wellbeing, it is important to contact a doctor.',
        'category': 'Safety',
        'created_at': now,
      },
    ];

    for (final article in articles) { //dodaj artykuły
      await db.insert('articles', article);
    }
  }

  Future<int> createUserProfile({ //tworzymy nowy profil
    required String login,
    required String displayName,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    final db = await database;

    final now = DateTime.now().toIso8601String(); //tworzy date

    return await db.insert('user_profile', { //zapis uzytk. pod inta
      'login': login,
      'display_name': displayName,
      'password_hash': passwordHash,
      'password_salt': passwordSalt,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<Map<String, dynamic>?> getUserProfileById(int userId) async { //pobierz użytk. po ID np. Home, ? - nieodnaleziony
  final db = await database;

  final result = await db.query(
    'user_profile',
    where: 'id = ?', //param. zapyt
    whereArgs: [userId],
    limit: 1,
  );

  if (result.isEmpty) {
    return null;
  }

  return result.first;
}

  Future<Map<String, dynamic>?> getUserByLogin(String login) async { //szuk. po loginie np. Rejestracja, logowanie
    final db = await database;

    final result = await db.query(
      'user_profile',
      where: 'login = ?',
      whereArgs: [login],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> updateUserDisplayName({ //aktualiz. nazwe
    required int userId,
    required String displayName,
  }) async {
    final db = await database;

    return await db.update(
      'user_profile',
      {
        'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getSymptoms() async { //pobiera list. symptomów z tabeli symptoms np. AddSymptomsScreen
    final db = await database;

    return await db.query('symptoms', orderBy: 'name ASC'); //alfabetycznie, rosnąco
  }

  Future<int> insertSymptomEntry({ //zapis symptomu na użytk. na konkretny dzień
    required int userId,
    required int symptomId,
    required String entryDate,
    String? note,
    int? intensity,
  }) async {
    final db = await database;

    final now = DateTime.now().toIso8601String();

    return await db.insert(
      'symptom_entries',
      {
        'user_id': userId,
        'symptom_id': symptomId,
        'entry_date': entryDate,
        'note': note,
        'intensity': intensity,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore, //ważne, połączone z unique
    );
  }

  Future<List<Map<String, dynamic>>> getSymptomEntriesByDate({ //pobiera sympt. z konrektnego dnia np. HomeSCreen, AddSymptomScreen, CalendarScreen
    required int userId,
    required String entryDate,
  }) async {
    final db = await database;

    return await db.rawQuery( //łączymy tabele wpisów z tabelą symptomów bo chcemy nazwę
      '''
      SELECT 
        symptom_entries.id,
        symptom_entries.symptom_id,
        symptom_entries.entry_date,
        symptom_entries.note,
        symptom_entries.intensity,
        symptoms.name AS symptom_name,
        symptoms.category AS symptom_category
      FROM symptom_entries
      INNER JOIN symptoms
        ON symptom_entries.symptom_id = symptoms.id
      WHERE symptom_entries.user_id = ?
        AND symptom_entries.entry_date = ?
      ORDER BY symptoms.name ASC
      ''',
      [userId, entryDate],
    );
  }

Future<List<Map<String, dynamic>>> getSymptomEntriesBetweenDates({ //pobiera wszystkie symp. z wybranego okresu np. ReportsScreen, CalendarScreen
  required int userId,
  required String startDate,
  required String endDate,
}) async {
  final db = await database;

  return await db.rawQuery(
    '''
    SELECT 
      symptom_entries.id,
      symptom_entries.symptom_id,
      symptom_entries.entry_date,
      symptom_entries.note,
      symptom_entries.intensity,
      symptoms.name AS symptom_name,
      symptoms.category AS symptom_category
    FROM symptom_entries
    INNER JOIN symptoms
      ON symptom_entries.symptom_id = symptoms.id
    WHERE symptom_entries.user_id = ?
      AND symptom_entries.entry_date BETWEEN ? AND ?
    ORDER BY symptom_entries.entry_date ASC, symptoms.name ASC
    ''',
    [userId, startDate, endDate],
  );
}

  Future<List<Map<String, dynamic>>> getAllSymptomEntries({ //pobiera wszystkei symp. użytkownika
    required int userId,
  }) async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT 
        symptom_entries.id,
        symptom_entries.entry_date,
        symptom_entries.note,
        symptom_entries.intensity,
        symptoms.name AS symptom_name,
        symptoms.category AS symptom_category
      FROM symptom_entries
      INNER JOIN symptoms
        ON symptom_entries.symptom_id = symptoms.id
      WHERE symptom_entries.user_id = ?
      ORDER BY symptom_entries.entry_date DESC
      ''',
      [userId],
    ); //ORDERBY najpierw najnowsze wpisy
  }

  Future<int> deleteSymptomEntry(int entryId) async { //usuwa pojedynczy wpis symptomu po ID
    final db = await database;

    return await db.delete(
      'symptom_entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  Future<List<Map<String, dynamic>>> getArticles() async { //pobiera wszystkie artykuły
    final db = await database;

    return await db.query('articles', orderBy: 'id ASC');
  }

  Future<Map<String, dynamic>?> getArticleById(int articleId) async {
    final db = await database;

    final result = await db.query(
      'articles',
      where: 'id = ?',
      whereArgs: [articleId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> insertReport({ //zapisuje wyg. raport do tab reports
    required int userId,
    required String startDate,
    required String endDate,
    required String summary,
  }) async {
    final db = await database;

    return await db.insert('reports', {
      'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      'summary': summary, //wyg przez report helper
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getReports({required int userId}) async { //pobiera historie raportów
    final db = await database;

    return await db.query(
      'reports',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> deleteReport(int reportId) async { //usuwa raport po ID
    final db = await database;

    return await db.delete(
      'reports',
      where: 'id = ?',  //usuń raport, którego id jest równe podanej wartości
      whereArgs: [reportId],
    );
  }

  Future<void> closeDatabase() async { //zamykapołączenie z bazą ustawia null
    final db = await database;

    await db.close();

    _database = null;
  }
}
