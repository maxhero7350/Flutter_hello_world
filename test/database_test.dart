// ===== FLUTTER TEST =====
import 'package:flutter_test/flutter_test.dart';

// ===== CUSTOM MODELS =====
import 'package:hello_world/models/message_model.dart' as message_model;

// ===== CUSTOM UTILS =====
import 'package:hello_world/utils/constants.dart' as constants;

void main() {
  group('MessageModel 測試', () {
    test('建立新訊息模型', () {
      // 建立測試訊息
      final message = message_model.MessageModel.create(content: '測試訊息');
      
      // 驗證訊息內容
      expect(message.content, '測試訊息');
      expect(message.id, isNull);
      expect(message.createdAt, isNotNull);
      expect(message.updatedAt, isNull);
    });

    test('從Map建立訊息模型', () {
      // 測試資料
      final testData = {
        'id': 1,
        'content': '測試內容',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': null,
      };
      
      // 從Map建立模型
      final message = message_model.MessageModel.fromMap(testData);
      
      // 驗證資料
      expect(message.id, 1);
      expect(message.content, '測試內容');
      expect(message.createdAt, isNotNull);
      expect(message.updatedAt, isNull);
    });

    test('轉換為Map', () {
      // 建立測試訊息
      final now = DateTime.now();
      final message = message_model.MessageModel(
        id: 1,
        content: '測試訊息',
        createdAt: now,
        updatedAt: null,
      );
      
      // 轉換為Map
      final map = message.toMap();
      
      // 驗證Map內容
      expect(map['id'], 1);
      expect(map['content'], '測試訊息');
      expect(map['created_at'], now.millisecondsSinceEpoch);
      expect(map['updated_at'], isNull);
    });

    test('更新訊息內容', () {
      // 建立原始訊息
      final originalMessage = message_model.MessageModel.create(content: '原始內容');
      
      // 更新內容
      final updatedMessage = originalMessage.updateContent('更新後的內容');
      
      // 驗證更新結果
      expect(updatedMessage.content, '更新後的內容');
      expect(updatedMessage.updatedAt, isNotNull);
      expect(updatedMessage.createdAt, originalMessage.createdAt);
    });

    test('JSON序列化和反序列化', () {
      // 建立測試訊息
      final originalMessage = message_model.MessageModel.create(content: 'JSON測試');
      
      // 轉換為JSON
      final jsonString = originalMessage.toJson();
      expect(jsonString, isNotEmpty);
      
      // 從JSON重建
      final reconstructedMessage = message_model.MessageModel.fromJson(jsonString);
      
      // 驗證重建的訊息
      expect(reconstructedMessage.content, originalMessage.content);
      // 比較毫秒數而非DateTime物件，避免精度問題
      expect(reconstructedMessage.createdAt.millisecondsSinceEpoch, 
             originalMessage.createdAt.millisecondsSinceEpoch);
    });

    test('訊息相等性比較', () {
      // 建立兩個相同的訊息
      final now = DateTime.now();
      final message1 = message_model.MessageModel(
        id: 1,
        content: '測試',
        createdAt: now,
        updatedAt: null,
      );
      
      final message2 = message_model.MessageModel(
        id: 1,
        content: '測試',
        createdAt: now,
        updatedAt: null,
      );
      
      // 驗證相等性
      expect(message1, equals(message2));
      expect(message1.hashCode, equals(message2.hashCode));
    });

    test('訊息不等性比較', () {
      // 建立兩個不同的訊息
      final now = DateTime.now();
      final message1 = message_model.MessageModel(
        id: 1,
        content: '測試1',
        createdAt: now,
        updatedAt: null,
      );
      
      final message2 = message_model.MessageModel(
        id: 2,
        content: '測試2',
        createdAt: now,
        updatedAt: null,
      );
      
      // 驗證不等性
      expect(message1, isNot(equals(message2)));
      expect(message1.hashCode, isNot(equals(message2.hashCode)));
    });
  });

  group('Constants 測試', () {
    test('資料庫常數', () {
      expect(constants.Constants.DATABASE_NAME, 'hello_world.db');
      expect(constants.Constants.DATABASE_VERSION, 1);
      expect(constants.Constants.TABLE_MESSAGES, 'messages');
    });

    test('欄位常數', () {
      expect(constants.Constants.COLUMN_ID, 'id');
      expect(constants.Constants.COLUMN_CONTENT, 'content');
      expect(constants.Constants.COLUMN_CREATED_AT, 'created_at');
      expect(constants.Constants.COLUMN_UPDATED_AT, 'updated_at');
    });

    test('驗證規則', () {
      expect(constants.Constants.MIN_MESSAGE_LENGTH, 1);
      expect(constants.Constants.MAX_MESSAGE_LENGTH, 500);
    });

    test('SQL建表語句', () {
      expect(constants.Constants.CREATE_TABLE_MESSAGES, contains('CREATE TABLE'));
      expect(constants.Constants.CREATE_TABLE_MESSAGES, contains(constants.Constants.TABLE_MESSAGES));
      expect(constants.Constants.CREATE_TABLE_MESSAGES, contains(constants.Constants.COLUMN_ID));
      expect(constants.Constants.CREATE_TABLE_MESSAGES, contains(constants.Constants.COLUMN_CONTENT));
    });
  });
} 