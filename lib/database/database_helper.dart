import 'package:flutter/foundation.dart';
import 'package:iptv/model/category_model.dart';
import 'package:iptv/model/edu_course_model.dart';
import 'package:iptv/model/edu_exam_model.dart';
import 'package:iptv/model/edu_lesson_model.dart';
import 'package:iptv/model/edu_level_model.dart';
import 'package:iptv/model/edu_question_model.dart';
import 'package:iptv/model/edu_result_model.dart';
import 'package:iptv/model/edu_semester_model.dart';
import 'package:iptv/model/edu_unit_model.dart';
import 'package:iptv/model/stream_model.dart';
import 'package:iptv/model/stream_series_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _webFactoryConfigured = false;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('iptv.db');
    return _database!;
  }

  // Future<Database> _initDB(String filePath) async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, filePath);

  //   return await openDatabase(path, version: 1, onCreate: _createDB);
  // }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      if (!_webFactoryConfigured) {
        databaseFactory = createDatabaseFactoryFfiWeb(
          options: SqfliteFfiWebOptions(
            sqlite3WasmUri: Uri.parse('/web/sqlite3.wasm'),
          ),
          noWebWorker: true,
        );
        _webFactoryConfigured = true;
      }
      const dbPath = 'iptv.db';
      return await openDatabase(dbPath,
          version: 7, onCreate: _createDB, onUpgrade: _upgradeDB);
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path,
          version: 7, onCreate: _createDB, onUpgrade: _upgradeDB);
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        category_id TEXT PRIMARY KEY,
        category_name TEXT,
        parent_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE streams (
        stream_id INTEGER PRIMARY KEY,
        num INTEGER,
        name TEXT,
        stream_type TEXT,
        stream_icon TEXT,
        epg_channel_id TEXT,
        added TEXT,
        category_id TEXT,
        plot TEXT,
        cast TEXT,
        director TEXT,
        genre TEXT,
        releaseDate TEXT,
        rating TEXT,
        backdrop_path TEXT,
        youtube_trailer TEXT,
        episode_run_time TEXT,
        custom_sid TEXT,
        tv_archive TEXT,
        direct_source TEXT,
        tv_archive_duration TEXT,
        live TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE movie_categories (
        category_id TEXT PRIMARY KEY,
        category_name TEXT,
        parent_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE movie_streams (
        stream_id INTEGER PRIMARY KEY,
        num INTEGER,
        name TEXT,
        stream_type TEXT,
        stream_icon TEXT,
        epg_channel_id TEXT,
        added TEXT,
        category_id TEXT,
        plot TEXT,
        cast TEXT,
        director TEXT,
        genre TEXT,
        releaseDate TEXT,
        rating TEXT,
        backdrop_path TEXT,
        youtube_trailer TEXT,
        episode_run_time TEXT,
        custom_sid TEXT,
        tv_archive TEXT,
        direct_source TEXT,
        tv_archive_duration TEXT,
        live TEXT,
        FOREIGN KEY (category_id) REFERENCES movie_categories(category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE series_categories (
        category_id TEXT PRIMARY KEY,
        category_name TEXT,
        parent_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE series_streams (
        series_id INTEGER PRIMARY KEY,
        num INTEGER,
        name TEXT,
        stream_type TEXT,
        cover TEXT,
        epg_channel_id TEXT,
        added TEXT,
        category_id TEXT,
        custom_sid TEXT,
        tv_archive TEXT,
        direct_source TEXT,
        tv_archive_duration TEXT,
        live TEXT,
        FOREIGN KEY (category_id) REFERENCES movie_categories(category_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE watch_progress (
        content_id TEXT,
        content_type TEXT,
        episode_id INTEGER,
        watched_duration INTEGER,
        total_duration INTEGER,
        PRIMARY KEY (content_id, episode_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE download_queue (
        queue_id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        name TEXT,
        isSeries INTEGER ,
        seriesName TEXT
      )
    ''');

    // ======= Educational Tables =======
    await _createEduTables(db);
  }

  Future<void> _createEduTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_levels (
        id INTEGER PRIMARY KEY,
        name TEXT,
        my_order INTEGER DEFAULT 0,
        is_general INTEGER DEFAULT 0,
        not_active INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_semesters (
        id INTEGER PRIMARY KEY,
        name TEXT,
        my_order INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_courses (
        id INTEGER PRIMARY KEY,
        name TEXT,
        level_id INTEGER,
        semester_id INTEGER,
        image TEXT,
        my_order INTEGER DEFAULT 0,
        unit_ids TEXT DEFAULT '',
        exam_ids TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_units (
        id INTEGER PRIMARY KEY,
        name TEXT,
        course_id INTEGER,
        my_order INTEGER DEFAULT 0,
        not_active INTEGER DEFAULT 0,
        exam_ids TEXT DEFAULT '',
        class_ids TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_lessons (
        id INTEGER PRIMARY KEY,
        name TEXT,
        unit_id INTEGER,
        lesson_link TEXT,
        lesson_link_type TEXT,
        backup_link TEXT,
        video_file TEXT,
        download_link TEXT,
        my_order INTEGER DEFAULT 0,
        is_watched INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_exams (
        id INTEGER PRIMARY KEY,
        name TEXT,
        course_id INTEGER,
        unit_id INTEGER,
        lesson_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_questions (
        id INTEGER PRIMARY KEY,
        question TEXT,
        question_type TEXT,
        question_image TEXT,
        marks REAL DEFAULT 1,
        exam_id INTEGER,
        parent_question_id INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_answers (
        id INTEGER PRIMARY KEY,
        answer TEXT,
        answer_image TEXT,
        answer_type TEXT,
        is_correct INTEGER DEFAULT 0,
        question_id INTEGER,
        hint_text TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS edu_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        exam_id INTEGER,
        exam_name TEXT,
        score REAL,
        total_marks REAL,
        percentage REAL,
        date_taken TEXT,
        user_answers TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS watch_progress (
          content_id TEXT,
          content_type TEXT,
          episode_id INTEGER,
          watched_duration INTEGER,
          total_duration INTEGER,
          PRIMARY KEY (content_id, episode_id)
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS download_queue (
        queue_id INTEGER PRIMARY KEY,
        url TEXT,
        name TEXT,
        isSeries INTEGER,
        seriesName TEXT
      )
    ''');
    }

    if (oldVersion < 4) {
      await _addColumnIfMissing(db, 'streams', 'direct_source', 'TEXT');
      await _addColumnIfMissing(db, 'movie_streams', 'direct_source', 'TEXT');
      await _addColumnIfMissing(db, 'series_streams', 'direct_source', 'TEXT');
    }

    if (oldVersion < 5) {
      await _createEduTables(db);
    }

    if (oldVersion < 6) {
      await _addSeriesMetadataColumns(db);
    }

    if (oldVersion < 7) {
      await _addSeriesMetadataColumns(db);
    }
  }

  Future<void> _addSeriesMetadataColumns(Database db) async {
    await _addColumnIfMissing(db, 'series_streams', 'plot', 'TEXT');
    await _addColumnIfMissing(db, 'series_streams', 'cast', 'TEXT');
    await _addColumnIfMissing(db, 'series_streams', 'director', 'TEXT');
    await _addColumnIfMissing(db, 'series_streams', 'genre', 'TEXT');
    await _addColumnIfMissing(db, 'series_streams', 'releaseDate', 'TEXT');
    await _addColumnIfMissing(db, 'series_streams', 'rating', 'TEXT');
    await _addColumnIfMissing(db, 'series_streams', 'backdrop_path', 'TEXT');
    await _addColumnIfMissing(db, 'series_streams', 'youtube_trailer', 'TEXT');
    await _addColumnIfMissing(db, 'series_streams', 'episode_run_time', 'TEXT');
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((item) => item['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<void> deleteWatchProgressByContentType(String contentType) async {
    final db = await instance.database;
    await db.delete(
      'watch_progress', // اسم الجدول
      where: 'content_type = ?', // شرط الحذف
      whereArgs: [contentType], // القيم التي سيتم تمريرها للشرط
    );
  }

  Future<void> saveProgress(
    String contentId,
    String contentType,
    int? episodeId,
    int watchedDuration,
    int totalDuration,
  ) async {
    final db = await instance.database;

    // تحقق إذا كان السجل موجودًا في قاعدة البيانات
    final result = await db.query(
      'watch_progress',
      where: 'content_id = ? ',
      whereArgs: [contentId],
    );

    if (result.isNotEmpty) {
      // إذا كان السجل موجودًا، قم بتحديثه
      await db.update(
        'watch_progress',
        {
          'content_id': contentId,
          'content_type': contentType,
          'episode_id': episodeId,
          'watched_duration': watchedDuration,
          'total_duration': totalDuration,
        },
        where: 'content_id = ?',
        whereArgs: [contentId],
      );
    } else {
      // إذا لم يكن السجل موجودًا، قم بإدراجه
      await db.insert(
        'watch_progress',
        {
          'content_id': contentId,
          'content_type': contentType,
          'episode_id': episodeId,
          'watched_duration': watchedDuration,
          'total_duration': totalDuration,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> addQueueDownload(Map<String, dynamic> download) async {
    final db = await database;
    return await db.insert('download_queue', download);
  }

  Future<List<Map<String, dynamic>>> getAllQueueDownloads() async {
    final db = await database;
    return await db.query('download_queue');
  }

  Future<int> deleteQueueDownload(int queueId) async {
    final db = await database;
    return await db
        .delete('download_queue', where: 'queue_id = ?', whereArgs: [queueId]);
  }

  Future<int?> getDownloadIdByName(String name) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'download_queue',
      columns: ['queue_id'],
      where: 'name = ?',
      whereArgs: [name],
    );

    if (result.isNotEmpty) {
      return result.first['queue_id'] as int;
    }
    return null; // إذا لم يتم العثور على أي نتيجة
  }

  Future<int> clearQueueDownloads() async {
    final db = await database;
    return await db.delete('download_queue');
  }

  Future<int> getProgress(String contentId, int? episodeId) async {
    final db = await instance.database;
    final result = await db.query(
      'watch_progress',
      columns: ['watched_duration'],
      where: 'content_id = ? AND episode_id = ?',
      whereArgs: [contentId, episodeId],
    );

    if (result.isNotEmpty) {
      return result.first['watched_duration'] as int;
    }
    return 0;
  }

  Future<void> resetProgress(String contentId, int? episodeId) async {
    final db = await instance.database;
    await db.delete(
      'watch_progress',
      where: 'content_id = ? AND episode_id = ?',
      whereArgs: [contentId, episodeId],
    );
  }

  // Functions for 'categories'
  Future<void> insertCategory(CategoryModel category) async {
    final db = await instance.database;
    await db.insert('categories', category.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<CategoryModel?> getCategory(String categoryId) async {
    final db = await instance.database;
    final maps = await db.query(
      'categories',
      columns: ['category_id', 'category_name', 'parent_id'],
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );

    if (maps.isNotEmpty) {
      return CategoryModel.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');

    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await instance.database;
    return db.update(
      'categories',
      category.toJson(),
      where: 'category_id = ?',
      whereArgs: [category.categoryId],
    );
  }

  Future<int> deleteCategory(String categoryId) async {
    final db = await instance.database;
    return await db.delete(
      'categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  // Functions for 'streams'
  Future<void> insertStream(List<StreamModel> streams) async {
    await _insertRows(
      'streams',
      streams.map((stream) => stream.toJson()),
    );
  }

  Future<List<StreamModel>> getAllStreams() async {
    final db = await instance.database;
    final result = await db.query('streams');

    return result.map((json) => StreamModel.fromJson(json)).toList();
  }

  // Functions for 'movie_categories'
  Future<void> insertMovieCategory(CategoryModel category) async {
    final db = await instance.database;
    await db.insert('movie_categories', category.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoryModel>> getAllMovieCategories() async {
    final db = await instance.database;
    final result = await db.query('movie_categories');

    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<void> clearWatchProgress() async {
    final db = await instance.database;
    await db
        .delete('watch_progress'); // حذف جميع السجلات من جدول watch_progress
  }

  // Functions for 'movie_streams'
  Future<void> insertMovieStream(List<StreamModel> streams) async {
    await _insertRows(
      'movie_streams',
      streams.map((stream) => stream.toJson()),
    );
  }

  Future<List<StreamModel>> getAllMovieStreams() async {
    final db = await instance.database;
    final result = await db.query(
      'movie_streams',
      orderBy: 'num DESC',
    );

    return result.map((json) => StreamModel.fromJson(json)).toList();
  }

  // Functions for 'series_categories'
  Future<void> insertSeriesCategory(CategoryModel category) async {
    final db = await instance.database;
    await db.insert('series_categories', category.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoryModel>> getAllSeriesCategories() async {
    final db = await instance.database;
    final result = await db.query('series_categories');

    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }

  // Functions for 'series_streams'
  Future<void> insertSeriesStream(List<StreamSeriesModel> streams) async {
    await _insertRows(
      'series_streams',
      streams.map((stream) => stream.toJson()),
    );
  }

  Future<void> _insertRows(
    String table,
    Iterable<Map<String, dynamic>> rows,
  ) async {
    final db = await instance.database;
    if (kIsWeb) {
      for (final row in rows) {
        await db.insert(
          table,
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      return;
    }

    const chunkSize = kIsWeb ? 200 : 1000;
    var batch = db.batch();
    var count = 0;

    for (final row in rows) {
      batch.insert(
        table,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      count++;

      if (count % chunkSize == 0) {
        await batch.commit(noResult: true);
        batch = db.batch();
      }
    }

    if (count % chunkSize != 0) {
      await batch.commit(noResult: true);
    }
  }

  Future<List<StreamSeriesModel>> getAllSeriesStreams() async {
    final db = await instance.database;
    final result = await db.query(
      'series_streams',
      orderBy: 'num DESC',
    );

    return result.map((json) => StreamSeriesModel.fromJson(json)).toList();
  }

  // Clear tables
  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('categories');
    await db.delete('streams');
    await db.delete('movie_categories');
    await db.delete('movie_streams');
    await db.delete('series_categories');
    await db.delete('series_streams');
    await db.delete('watch_progress');
  }

  Future<void> clearCategories() async {
    final db = await instance.database;
    await db.delete('categories');
  }

  Future<void> clearStreams() async {
    final db = await instance.database;
    await db.delete('streams');
  }

  Future<void> clearMovieCategories() async {
    final db = await instance.database;
    await db.delete('movie_categories');
  }

  Future<void> clearMovieStreams() async {
    final db = await instance.database;
    await db.delete('movie_streams');
  }

  Future<void> clearSeriesCategories() async {
    final db = await instance.database;
    await db.delete('series_categories');
  }

  Future<void> clearSeriesStreams() async {
    final db = await instance.database;
    await db.delete('series_streams');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // ============================================================
  // Educational System CRUD Methods
  // ============================================================

  // --- Levels ---
  Future<void> upsertEduLevels(List<EduLevel> levels) async {
    final db = await database;
    final batch = db.batch();
    for (final l in levels) {
      batch.insert('edu_levels', l.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<EduLevel>> getEduLevels() async {
    final db = await database;
    final maps = await db.query('edu_levels', orderBy: 'my_order ASC');
    return maps.map(EduLevel.fromMap).toList();
  }

  Future<EduLevel?> getEduLevelById(int id) async {
    final db = await database;
    final maps = await db.query('edu_levels', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? EduLevel.fromMap(maps.first) : null;
  }

  // --- Semesters ---
  Future<void> upsertEduSemesters(List<EduSemester> semesters) async {
    final db = await database;
    final batch = db.batch();
    for (final s in semesters) {
      batch.insert('edu_semesters', s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<EduSemester>> getEduSemesters() async {
    final db = await database;
    final maps = await db.query('edu_semesters', orderBy: 'my_order ASC');
    return maps.map(EduSemester.fromMap).toList();
  }

  // --- Courses ---
  Future<void> upsertEduCourses(List<EduCourse> courses) async {
    final db = await database;
    final batch = db.batch();
    for (final c in courses) {
      batch.insert('edu_courses', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<EduCourse>> getEduCourses({int? levelId, int? semesterId}) async {
    final db = await database;
    String? where;
    List<dynamic> whereArgs = [];
    if (levelId != null && semesterId != null) {
      where = 'level_id = ? AND semester_id = ?';
      whereArgs = [levelId, semesterId];
    } else if (levelId != null) {
      where = 'level_id = ?';
      whereArgs = [levelId];
    }
    final maps = await db.query('edu_courses',
        where: where,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'my_order ASC');
    return maps.map(EduCourse.fromMap).toList();
  }

  Future<EduCourse?> getEduCourseById(int id) async {
    final db = await database;
    final maps =
        await db.query('edu_courses', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? EduCourse.fromMap(maps.first) : null;
  }

  // --- Units ---
  Future<void> upsertEduUnits(List<EduUnit> units) async {
    final db = await database;
    final batch = db.batch();
    for (final u in units) {
      batch.insert('edu_units', u.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<EduUnit>> getEduUnits({required int courseId}) async {
    final db = await database;
    final maps = await db.query('edu_units',
        where: 'course_id = ?', whereArgs: [courseId], orderBy: 'my_order ASC');
    return maps.map(EduUnit.fromMap).toList();
  }

  Future<List<EduUnit>> getEduUnitsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final maps = await db.query(
      'edu_units',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
      orderBy: 'my_order ASC',
    );
    final units = maps.map(EduUnit.fromMap).toList();
    final byId = {for (final unit in units) unit.id: unit};
    return ids.where(byId.containsKey).map((id) => byId[id]!).toList();
  }

  Future<EduUnit?> getEduUnitById(int id) async {
    final db = await database;
    final maps = await db.query('edu_units', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? EduUnit.fromMap(maps.first) : null;
  }

  // --- Lessons ---
  Future<void> upsertEduLessons(List<EduLesson> lessons) async {
    final db = await database;
    final batch = db.batch();
    for (final l in lessons) {
      batch.insert('edu_lessons', l.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<EduLesson>> getEduLessons({required int unitId}) async {
    final db = await database;
    final maps = await db.query('edu_lessons',
        where: 'unit_id = ?', whereArgs: [unitId], orderBy: 'my_order ASC');
    return maps.map(EduLesson.fromMap).toList();
  }

  Future<EduLesson?> getEduLessonById(int id) async {
    final db = await database;
    final maps =
        await db.query('edu_lessons', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? EduLesson.fromMap(maps.first) : null;
  }

  Future<void> markLessonWatched(int lessonId, bool watched) async {
    final db = await database;
    await db.update('edu_lessons', {'is_watched': watched ? 1 : 0},
        where: 'id = ?', whereArgs: [lessonId]);
  }

  // --- Exams ---
  Future<void> upsertEduExam(EduExam exam) async {
    final db = await database;
    await db.insert('edu_exams', exam.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<EduExam?> getEduExam(int examId) async {
    final db = await database;
    final maps =
        await db.query('edu_exams', where: 'id = ?', whereArgs: [examId]);
    return maps.isNotEmpty ? EduExam.fromMap(maps.first) : null;
  }

  // --- Questions ---
  Future<void> upsertEduQuestions(List<EduQuestion> questions) async {
    final db = await database;
    final batch = db.batch();
    for (final q in questions) {
      batch.insert('edu_questions', q.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<EduQuestion>> getEduQuestions({required int examId}) async {
    final db = await database;
    final maps = await db
        .query('edu_questions', where: 'exam_id = ?', whereArgs: [examId]);
    return maps.map(EduQuestion.fromMap).toList();
  }

  // --- Answers ---
  Future<void> upsertEduAnswers(List<EduAnswer> answers) async {
    final db = await database;
    final batch = db.batch();
    for (final a in answers) {
      batch.insert('edu_answers', a.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<EduAnswer>> getEduAnswers({required int questionId}) async {
    final db = await database;
    final maps = await db.query('edu_answers',
        where: 'question_id = ?', whereArgs: [questionId]);
    return maps.map(EduAnswer.fromMap).toList();
  }

  // --- Results ---
  Future<int> saveEduResult(EduResult result) async {
    final db = await database;
    return await db.insert('edu_results', result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<EduResult>> getEduResults({String? userId}) async {
    final db = await database;
    final maps = await db.query('edu_results',
        where: userId != null ? 'user_id = ?' : null,
        whereArgs: userId != null ? [userId] : null,
        orderBy: 'date_taken DESC');
    return maps.map(EduResult.fromMap).toList();
  }

  Future<List<EduResult>> getEduResultsForExam(int examId) async {
    final db = await database;
    final maps = await db.query('edu_results',
        where: 'exam_id = ?', whereArgs: [examId], orderBy: 'date_taken DESC');
    return maps.map(EduResult.fromMap).toList();
  }
}
