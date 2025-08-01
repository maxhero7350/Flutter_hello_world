import 'dart:convert';

/// TimeData資料模型
/// 用於C頁面顯示API回傳的時間資料
class TimeDataModel {
  final String timezone;
  final String datetime;
  final String utcDatetime;
  final int utcOffset;
  final int dayOfWeek;
  final int dayOfYear;
  final int weekNumber;
  final DateTime fetchedAt;

  const TimeDataModel({
    required this.timezone,
    required this.datetime,
    required this.utcDatetime,
    required this.utcOffset,
    required this.dayOfWeek,
    required this.dayOfYear,
    required this.weekNumber,
    required this.fetchedAt,
  });

  /// 從API回應建立TimeDataModel
  factory TimeDataModel.fromApiResponse(Map<String, dynamic> map) {
    return TimeDataModel(
      timezone: map['timezone'] as String? ?? 'Unknown',
      datetime: map['datetime'] as String? ?? '',
      utcDatetime: map['utc_datetime'] as String? ?? '',
      utcOffset: map['utc_offset'] as int? ?? 0,
      dayOfWeek: map['day_of_week'] as int? ?? 0,
      dayOfYear: map['day_of_year'] as int? ?? 0,
      weekNumber: map['week_number'] as int? ?? 0,
      fetchedAt: DateTime.now(),
    );
  }

  /// 從本地時間建立TimeDataModel（當API失敗時使用）
  factory TimeDataModel.createFromLocalTime() {
    final now = DateTime.now();
    final utcNow = now.toUtc();

    return TimeDataModel(
      timezone: 'Asia/Taipei',
      datetime: now.toIso8601String(),
      utcDatetime: utcNow.toIso8601String(),
      utcOffset: 8 * 60 * 60, // UTC+8 for Taiwan
      dayOfWeek: now.weekday,
      dayOfYear: now.difference(DateTime(now.year, 1, 1)).inDays + 1,
      weekNumber: ((now.difference(DateTime(now.year, 1, 1)).inDays + 1) / 7)
          .ceil(),
      fetchedAt: now,
    );
  }

  /// 從本地端儲存Map建立TimeDataModel
  factory TimeDataModel.fromMap(Map<String, dynamic> map) {
    return TimeDataModel(
      timezone: map['timezone'] as String,
      datetime: map['datetime'] as String,
      utcDatetime: map['utc_datetime'] as String,
      utcOffset: map['utc_offset'] as int,
      dayOfWeek: map['day_of_week'] as int,
      dayOfYear: map['day_of_year'] as int,
      weekNumber: map['week_number'] as int,
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(map['fetched_at'] as int),
    );
  }

  /// 轉換為本地端儲存Map
  Map<String, dynamic> toMap() {
    return {
      'timezone': timezone,
      'datetime': datetime,
      'utc_datetime': utcDatetime,
      'utc_offset': utcOffset,
      'day_of_week': dayOfWeek,
      'day_of_year': dayOfYear,
      'week_number': weekNumber,
      'fetched_at': fetchedAt.millisecondsSinceEpoch,
    };
  }

  /// 從JSON字串建立TimeDataModel
  factory TimeDataModel.fromJson(String source) {
    return TimeDataModel.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  /// 轉換為JSON字串
  String toJson() => json.encode(toMap());

  /// 格式化顯示的日期時間
  String get formattedDateTime {
    try {
      final dateTime = DateTime.parse(datetime);
      return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return datetime;
    }
  }

  /// 格式化顯示的時區
  String get formattedTimezone {
    return timezone.replaceAll('_', ' ');
  }

  /// 取得星期幾的文字
  String get weekDayText {
    const weekDays = ['', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return weekDays[dayOfWeek];
    }
    return '未知';
  }

  /// 檢查資料是否已過期（超過1小時）
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(fetchedAt);
    return difference.inHours > 1;
  }

  @override
  String toString() {
    return 'TimeDataModel(timezone: $timezone, datetime: $datetime, fetchedAt: $fetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimeDataModel &&
        other.timezone == timezone &&
        other.datetime == datetime &&
        other.utcDatetime == utcDatetime &&
        other.utcOffset == utcOffset &&
        other.dayOfWeek == dayOfWeek &&
        other.dayOfYear == dayOfYear &&
        other.weekNumber == weekNumber &&
        other.fetchedAt == fetchedAt;
  }

  @override
  int get hashCode {
    return timezone.hashCode ^
        datetime.hashCode ^
        utcDatetime.hashCode ^
        utcOffset.hashCode ^
        dayOfWeek.hashCode ^
        dayOfYear.hashCode ^
        weekNumber.hashCode ^
        fetchedAt.hashCode;
  }
}
