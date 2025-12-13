import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

/// Local SQLite Database Service for Offline Caching
class LocalDbService {
  static Database? _database;
  static const String _dbName = 'doctorclinic_cache.db';
  static const int _dbVersion = 1;

  Future<void> init() async {
    if (_database != null) return;
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    developer.log('✅ Local database initialized', name: 'LocalDbService');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Doctors Table
    await db.execute('''
      CREATE TABLE doctors (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Appointments Table
    await db.execute('''
      CREATE TABLE appointments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Reviews Table
    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        doctor_id TEXT NOT NULL,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Cache Metadata Table
    await db.execute('''
      CREATE TABLE cache_meta (
        key TEXT PRIMARY KEY,
        last_updated INTEGER NOT NULL
      )
    ''');

    developer.log('✅ Database tables created', name: 'LocalDbService');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here in future
    developer.log('🔄 Database upgraded from $oldVersion to $newVersion', name: 'LocalDbService');
  }

  // ============== DOCTORS CACHE ==============

  Future<void> cacheDoctors(List<DoctorModel> doctors) async {
    if (_database == null) await init();
    
    final batch = _database!.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Clear old doctors
    batch.delete('doctors');

    // Insert new doctors
    for (final doctor in doctors) {
      batch.insert('doctors', {
        'id': doctor.id,
        'data': jsonEncode(doctor.toFirestore()),
        'updated_at': now,
      });
    }

    // Update cache meta
    batch.insert(
      'cache_meta',
      {'key': 'doctors_last_updated', 'last_updated': now},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await batch.commit(noResult: true);
    developer.log('💾 Cached ${doctors.length} doctors', name: 'LocalDbService');
  }

  Future<List<DoctorModel>> getCachedDoctors() async {
    if (_database == null) await init();

    try {
      final results = await _database!.query('doctors');
      
      return results.map((row) {
        final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
        data['id'] = row['id'];
        return DoctorModel.fromMap(data);
      }).toList();
    } catch (e) {
      developer.log('❌ Error reading cached doctors: $e', name: 'LocalDbService');
      return [];
    }
  }

  Future<DateTime?> getDoctorsCacheTime() async {
    if (_database == null) await init();

    try {
      final results = await _database!.query(
        'cache_meta',
        where: 'key = ?',
        whereArgs: ['doctors_last_updated'],
      );

      if (results.isNotEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(
          results.first['last_updated'] as int,
        );
      }
    } catch (e) {
      developer.log('❌ Error reading cache time: $e', name: 'LocalDbService');
    }
    return null;
  }

  // ============== APPOINTMENTS CACHE ==============

  Future<void> cacheAppointments(List<AppointmentModel> appointments, String userId) async {
    if (_database == null) await init();

    final batch = _database!.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Clear old appointments for this user
    batch.delete('appointments', where: 'user_id = ?', whereArgs: [userId]);

    // Insert new appointments
    for (final appointment in appointments) {
      batch.insert('appointments', {
        'id': appointment.id,
        'user_id': userId,
        'data': jsonEncode(appointment.toFirestore()),
        'updated_at': now,
      });
    }

    // Update cache meta
    batch.insert(
      'cache_meta',
      {'key': 'appointments_${userId}_last_updated', 'last_updated': now},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await batch.commit(noResult: true);
    developer.log('💾 Cached ${appointments.length} appointments', name: 'LocalDbService');
  }

  Future<List<AppointmentModel>> getCachedAppointments(String userId) async {
    if (_database == null) await init();

    try {
      final results = await _database!.query(
        'appointments',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      return results.map((row) {
        final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
        data['id'] = row['id'];
        return AppointmentModel.fromMap(data);
      }).toList();
    } catch (e) {
      developer.log('❌ Error reading cached appointments: $e', name: 'LocalDbService');
      return [];
    }
  }

  // ============== REVIEWS CACHE ==============

  Future<void> cacheReviews(List<Map<String, dynamic>> reviews, String doctorId) async {
    if (_database == null) await init();

    final batch = _database!.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Clear old reviews for this doctor
    batch.delete('reviews', where: 'doctor_id = ?', whereArgs: [doctorId]);

    // Insert new reviews
    for (final review in reviews) {
      batch.insert('reviews', {
        'id': review['id'],
        'doctor_id': doctorId,
        'data': jsonEncode(review),
        'updated_at': now,
      });
    }

    await batch.commit(noResult: true);
  }

  // ============== CLEAR CACHE ==============

  Future<void> clearDoctorsCache() async {
    if (_database == null) return;
    await _database!.delete('doctors');
    await _database!.delete('cache_meta', where: 'key = ?', whereArgs: ['doctors_last_updated']);
  }

  Future<void> clearAppointmentsCache(String userId) async {
    if (_database == null) return;
    await _database!.delete('appointments', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> clearAll() async {
    if (_database == null) return;
    await _database!.delete('doctors');
    await _database!.delete('appointments');
    await _database!.delete('reviews');
    await _database!.delete('cache_meta');
    developer.log('🗑️ All cache cleared', name: 'LocalDbService');
  }

  // ============== CACHE STATUS ==============

  Future<bool> isCacheStale(String key, {Duration maxAge = const Duration(hours: 1)}) async {
    final cacheTime = await _getCacheTime(key);
    if (cacheTime == null) return true;

    return DateTime.now().difference(cacheTime) > maxAge;
  }

  Future<DateTime?> _getCacheTime(String key) async {
    if (_database == null) await init();

    try {
      final results = await _database!.query(
        'cache_meta',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (results.isNotEmpty) {
        return DateTime.fromMillisecondsSinceEpoch(
          results.first['last_updated'] as int,
        );
      }
    } catch (e) {
      developer.log('❌ Error: $e', name: 'LocalDbService');
    }
    return null;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
