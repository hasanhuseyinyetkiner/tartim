import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path,
        version: 4, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create animals table
    await db.execute('''
      CREATE TABLE animals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type_id INTEGER NOT NULL,
        ear_tag TEXT NOT NULL,
        rfid TEXT NOT NULL UNIQUE,
        mother_rfid TEXT,
        father_rfid TEXT,
        FOREIGN KEY (type_id) REFERENCES animal_types (id)
      )
    ''');

    // Create animal_types table with new fields
    await db.execute('''
      CREATE TABLE animal_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        sort_order INTEGER NOT NULL
      )
    ''');

    // Insert default animal types with categories
    // Büyükbaş
    await db.insert('animal_types',
        {'name': 'İnek', 'category': 'Büyükbaş', 'sort_order': 1});
    await db.insert('animal_types',
        {'name': 'Buzağı', 'category': 'Büyükbaş', 'sort_order': 2});
    await db.insert('animal_types',
        {'name': 'Düve', 'category': 'Büyükbaş', 'sort_order': 3});
    await db.insert('animal_types',
        {'name': 'Boğa', 'category': 'Büyükbaş', 'sort_order': 4});
    await db.insert('animal_types',
        {'name': 'Tosun', 'category': 'Büyükbaş', 'sort_order': 5});

    // Koyun
    await db.insert('animal_types',
        {'name': 'Koyun', 'category': 'Koyun', 'sort_order': 6});
    await db.insert(
        'animal_types', {'name': 'Kuzu', 'category': 'Koyun', 'sort_order': 7});
    await db.insert(
        'animal_types', {'name': 'Koç', 'category': 'Koyun', 'sort_order': 8});

    // Keçi
    await db.insert(
        'animal_types', {'name': 'Keçi', 'category': 'Keçi', 'sort_order': 9});
    await db.insert('animal_types',
        {'name': 'Oğlak', 'category': 'Keçi', 'sort_order': 10});
    await db.insert(
        'animal_types', {'name': 'Teke', 'category': 'Keçi', 'sort_order': 11});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add olcumTipi column to the measurements table
      await db.execute(
          'ALTER TABLE measurements ADD COLUMN olcumTipi INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE temp_measurements ADD COLUMN olcumTipi INTEGER DEFAULT 0');
    }

    if (oldVersion < 3) {
      // Add mother_rfid and father_rfid columns to animals table
      await db.execute('ALTER TABLE animals ADD COLUMN mother_rfid TEXT');
      await db.execute('ALTER TABLE animals ADD COLUMN father_rfid TEXT');
    }

    if (oldVersion < 4) {
      // Add category and sort_order columns to animal_types table
      await db.execute(
          'ALTER TABLE animal_types ADD COLUMN category TEXT DEFAULT ""');
      await db.execute(
          'ALTER TABLE animal_types ADD COLUMN sort_order INTEGER DEFAULT 0');

      // Update existing records with categories and sort orders
      await db.execute(
          "UPDATE animal_types SET category = 'Büyükbaş', sort_order = 1 WHERE name = 'İnek'");
      await db.execute(
          "UPDATE animal_types SET category = 'Büyükbaş', sort_order = 2 WHERE name = 'Buzağı'");
      await db.execute(
          "UPDATE animal_types SET category = 'Büyükbaş', sort_order = 3 WHERE name = 'Düve'");
      await db.execute(
          "UPDATE animal_types SET category = 'Büyükbaş', sort_order = 4 WHERE name = 'Boğa'");
      await db.execute(
          "UPDATE animal_types SET category = 'Büyükbaş', sort_order = 5 WHERE name = 'Tosun'");
      await db.execute(
          "UPDATE animal_types SET category = 'Koyun', sort_order = 6 WHERE name = 'Koyun'");
      await db.execute(
          "UPDATE animal_types SET category = 'Koyun', sort_order = 7 WHERE name = 'Kuzu'");
      await db.execute(
          "UPDATE animal_types SET category = 'Koyun', sort_order = 8 WHERE name = 'Koç'");
      await db.execute(
          "UPDATE animal_types SET category = 'Keçi', sort_order = 9 WHERE name = 'Keçi'");
      await db.execute(
          "UPDATE animal_types SET category = 'Keçi', sort_order = 10 WHERE name = 'Oğlak'");
      await db.execute(
          "UPDATE animal_types SET category = 'Keçi', sort_order = 11 WHERE name = 'Teke'");
    }
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where,
      List<dynamic>? whereArgs,
      String? orderBy,
      int? limit}) async {
    final db = await instance.database;
    return await db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs, {
    String? orderBy,
    int? limit,
  }) async {
    final db = await instance.database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(String table, Map<String, dynamic> row, String where,
      List<dynamic> whereArgs) async {
    final db = await instance.database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
      String table, String? where, List<dynamic>? whereArgs) async {
    final db = await instance.database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> transaction(
      Future<void> Function(Transaction txn) action) async {
    final db = await instance.database;
    await db.transaction(action);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    final db = await instance.database;
    return await db.rawQuery(sql, arguments);
  }
}
