import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _db;
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initMyDb();
    return _db!;
  }
  static Future<Database> _initMyDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'attendance_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE groups (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)'
        );
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            group_name TEXT, 
            student_name TEXT, 
            status TEXT, 
            date TEXT,
            lesson_number INTEGER, 
            UNIQUE(group_name, student_name, date, lesson_number)
          )
        ''');
      },
    );
  }
  static Future<void> addGroup(String groupName) async {
    final myDb = await database;
    await myDb.insert(
        'groups',
        {'name': groupName},
        conflictAlgorithm: ConflictAlgorithm.ignore
    );
  }
  static Future<List<String>> getGroups() async {
    final myDb = await database;
    final List<Map<String, dynamic>> result = await myDb.query('groups');
    List<String> foundGroups = [];
    for (var row in result) {
      foundGroups.add(row['name'] as String);
    }
    return foundGroups;
  }
  static Future<void> deleteGroup(String groupName) async {
    final myDb = await database;
    await myDb.delete('groups', where: 'name = ?', whereArgs: [groupName]);
    await myDb.delete('students', where: 'group_name = ?', whereArgs: [groupName]);
  }
  static Future<void> saveStudentStatus(String gName, String sName, String currentStatus, String curDate, int lessonNum) async {
    final myDb = await database;
    Map<String, dynamic> rowToSave = {
      'group_name': gName,
      'student_name': sName,
      'status': currentStatus,
      'date': curDate,
      'lesson_number': lessonNum
    };
    await myDb.insert(
      'students',
      rowToSave,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<List<Map<String, dynamic>>> loadStudents(String gName, String curDate, int lessonNum) async {
    final myDb = await database;
    return await myDb.query(
        'students',
        where: 'group_name = ? AND date = ? AND lesson_number = ?',
        whereArgs: [gName, curDate, lessonNum]
    );
  }
  static Future<List<String>> getAllStudentNamesInGroup(String gName) async {
    final myDb = await database;
    final List<Map<String, dynamic>> rows = await myDb.rawQuery(
        'SELECT DISTINCT student_name FROM students WHERE group_name = ?',
        [gName]
    );
    return rows.map((e) => e['student_name'] as String).toList();
  }
  static Future<void> deleteStudent(String gName, String sName) async {
    final myDb = await database;
    await myDb.delete(
        'students',
        where: 'group_name = ? AND student_name = ?',
        whereArgs: [gName, sName]
    );
  }
}