import 'dart:convert';

/// Message資料模型
/// 用於B頁面儲存使用者輸入的訊息
class MessageModel {
  final int? id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MessageModel({
    this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  /// 建立新訊息（沒有ID，用於插入資料庫前）
  factory MessageModel.create({
    required String content,
  }) {
    return MessageModel(
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// 從資料庫Map建立MessageModel
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as int?,
      content: map['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  /// 轉換為資料庫Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// 從JSON字串建立MessageModel
  factory MessageModel.fromJson(String source) {
    return MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  /// 轉換為JSON字串
  String toJson() => json.encode(toMap());

  /// 建立副本並更新特定欄位
  MessageModel copyWith({
    int? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 更新訊息內容
  MessageModel updateContent(String newContent) {
    return copyWith(
      content: newContent,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, content: $content, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MessageModel &&
        other.id == id &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 