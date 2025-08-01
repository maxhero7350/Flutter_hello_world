import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/message_model.dart' as message_model;
import '../utils/constants.dart' as constants;

/// SQLite資料庫服務
/// 處理資料庫初始化、連接管理和所有CRUD操作
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // 單例模式
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// 取得資料庫實例
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// STEP 01: 初始化資料庫
  Future<Database> _initDatabase() async {
    try {
      // STEP 01.01: 取得應用程式文件目錄
      Directory documentsDirectory = await getApplicationDocumentsDirectory();

      // STEP 01.02: 建立資料庫檔案路徑
      String path = join(
        documentsDirectory.path,
        constants.Constants.DATABASE_NAME,
      );

      // STEP 01.03: 開啟或建立資料庫
      return await openDatabase(
        path,
        version: constants.Constants.DATABASE_VERSION,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 初始化失敗 - $e');
    }
  }

  /// STEP 02: 建立資料庫表格
  Future<void> _createDatabase(Database db, int version) async {
    try {
      // STEP 02.01: 建立Messages表格
      await db.execute(constants.Constants.CREATE_TABLE_MESSAGES);

      print('資料庫表格建立成功');
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 建立表格失敗 - $e');
    }
  }

  /// STEP 03: 升級資料庫
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      // 目前版本為1，暫無升級邏輯
      print('資料庫從版本 $oldVersion 升級到版本 $newVersion');
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 升級失敗 - $e');
    }
  }

  /// STEP 04: 新增訊息到資料庫
  Future<int> insertMessage(message_model.MessageModel message) async {
    try {
      // STEP 04.01: 取得資料庫實例
      final db = await database;

      // STEP 04.02: 準備資料（排除ID，因為是自動增長）
      final messageData = message.toMap();
      messageData.remove(constants.Constants.COLUMN_ID);

      // STEP 04.03: 插入資料並回傳新ID
      final id = await db.insert(
        constants.Constants.TABLE_MESSAGES,
        messageData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('訊息插入成功，ID: $id');
      return id;
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 插入訊息失敗 - $e');
    }
  }

  /// STEP 05: 取得所有訊息
  Future<List<message_model.MessageModel>> getAllMessages() async {
    try {
      // STEP 05.01: 取得資料庫實例
      final db = await database;

      // STEP 05.02: 查詢所有訊息（按建立時間倒序）
      final List<Map<String, dynamic>> maps = await db.query(
        constants.Constants.TABLE_MESSAGES,
        orderBy: '${constants.Constants.COLUMN_CREATED_AT} DESC',
      );

      // STEP 05.03: 轉換為MessageModel列表
      return List.generate(maps.length, (index) {
        return message_model.MessageModel.fromMap(maps[index]);
      });
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 取得訊息失敗 - $e');
    }
  }

  /// STEP 06: 根據ID取得特定訊息
  Future<message_model.MessageModel?> getMessageById(int id) async {
    try {
      // STEP 06.01: 取得資料庫實例
      final db = await database;

      // STEP 06.02: 查詢特定ID的訊息
      final List<Map<String, dynamic>> maps = await db.query(
        constants.Constants.TABLE_MESSAGES,
        where: '${constants.Constants.COLUMN_ID} = ?',
        whereArgs: [id],
      );

      // STEP 06.03: 回傳結果
      if (maps.isNotEmpty) {
        return message_model.MessageModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 取得特定訊息失敗 - $e');
    }
  }

  /// STEP 07: 更新訊息
  Future<int> updateMessage(message_model.MessageModel message) async {
    try {
      // STEP 07.01: 檢查訊息是否有ID
      if (message.id == null) {
        throw Exception('訊息ID不能為空');
      }

      // STEP 07.02: 取得資料庫實例
      final db = await database;

      // STEP 07.03: 更新訊息
      final rowsAffected = await db.update(
        constants.Constants.TABLE_MESSAGES,
        message.toMap(),
        where: '${constants.Constants.COLUMN_ID} = ?',
        whereArgs: [message.id],
      );

      print('訊息更新成功，影響行數: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 更新訊息失敗 - $e');
    }
  }

  /// STEP 08: 刪除訊息
  Future<int> deleteMessage(int id) async {
    try {
      // STEP 08.01: 取得資料庫實例
      final db = await database;

      // STEP 08.02: 刪除指定ID的訊息
      final rowsAffected = await db.delete(
        constants.Constants.TABLE_MESSAGES,
        where: '${constants.Constants.COLUMN_ID} = ?',
        whereArgs: [id],
      );

      print('訊息刪除成功，影響行數: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 刪除訊息失敗 - $e');
    }
  }

  /// STEP 09: 取得訊息總數
  Future<int> getMessageCount() async {
    try {
      // STEP 09.01: 取得資料庫實例
      final db = await database;

      // STEP 09.02: 計算訊息總數
      final count =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${constants.Constants.TABLE_MESSAGES}',
            ),
          ) ??
          0;

      return count;
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 取得訊息數量失敗 - $e');
    }
  }

  /// STEP 10: 清空所有訊息
  Future<int> clearAllMessages() async {
    try {
      // STEP 10.01: 取得資料庫實例
      final db = await database;

      // STEP 10.02: 刪除所有訊息
      final rowsAffected = await db.delete(constants.Constants.TABLE_MESSAGES);

      print('所有訊息清空成功，影響行數: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      throw Exception('${constants.Constants.ERROR_DATABASE}: 清空訊息失敗 - $e');
    }
  }

  /// STEP 11: 關閉資料庫連接
  Future<void> closeDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
        print('資料庫連接已關閉');
      }
    } catch (e) {
      print('關閉資料庫失敗: $e');
    }
  }

  /// STEP 12: 檢查資料庫是否存在
  Future<bool> isDatabaseExists() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(
        documentsDirectory.path,
        constants.Constants.DATABASE_NAME,
      );
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  /// STEP 13: 取得資料庫檔案大小（bytes）
  Future<int> getDatabaseSize() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(
        documentsDirectory.path,
        constants.Constants.DATABASE_NAME,
      );
      File dbFile = File(path);

      if (await dbFile.exists()) {
        return await dbFile.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
