/// HelloWorld應用程式常數定義
class Constants {
  // 防止實例化
  Constants._();

  // ===== 應用程式基本資訊 =====
  static const String appName = 'HelloWorld';
  static const String appVersion = '1.0.0';

  // ===== 資料庫相關常數 =====
  static const String databaseName = 'hello_world.db';
  static const int databaseVersion = 1;

  // 資料表名稱
  static const String tableMessages = 'messages';

  // Messages資料表欄位
  static const String columnId = 'id';
  static const String columnContent = 'content';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // ===== API相關常數 =====
  // 使用更穩定的時間API
  static const String timeApiBaseUrl = 'https://worldtimeapi.org/api';
  static const String timeApiTimezone = 'timezone/Asia/Taipei';
  static const String timeApiFullUrl = '$timeApiBaseUrl/$timeApiTimezone';

  // 備用時間API（如果主要API失敗）
  static const String backupTimeApiUrl =
      'https://timeapi.io/api/time/current/zone?timeZone=Asia/Taipei';

  // API請求逾時時間（秒）
  static const int apiTimeoutSeconds = 30;

  // ===== UI相關常數 =====
  // 間距
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // 圓角半徑
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;

  // 字體大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeExtraLarge = 24.0;

  // 圖標大小
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  // ===== 動畫相關常數 =====
  // 側邊欄動畫時間（毫秒）
  static const int sidebarAnimationDuration = 300;
  // 側邊欄動畫曲線
  static const String sidebarAnimationCurve = 'easeInOut';

  // ===== 頁面標識 =====
  static const String pageLogin = 'login';
  static const String pageMain = 'main';
  static const String pageA = 'pageA';
  static const String pageA1 = 'pageA1';
  static const String pageA2 = 'pageA2';
  static const String pageB = 'pageB';
  static const String pageC = 'pageC';

  // ===== 本地存儲Key =====
  static const String prefFirstRun = 'first_run';
  static const String prefUserName = 'user_name';
  static const String prefLastTimeData = 'last_time_data';
  static const String prefOfflineSettings = 'offline_settings';
  static const String prefApiHistory = 'api_history';
  static const String prefOfflineQueue = 'offline_queue';
  static const String prefNetworkHistory = 'network_history';

  // ===== 錯誤訊息 =====
  static const String errorNetwork = '網路連線錯誤，請檢查網路設定';
  static const String errorDatabase = '資料庫操作錯誤';
  static const String errorApi = 'API呼叫失敗';
  static const String errorValidation = '輸入資料格式錯誤';
  static const String errorUnknown = '發生未知錯誤';

  // ===== 成功訊息 =====
  static const String successMessageSaved = '訊息已成功儲存';
  static const String successMessageUpdated = '訊息已成功更新';
  static const String successMessageDeleted = '訊息已成功刪除';
  static const String successTimeFetched = '時間資料已成功取得';
  static const String successOfflineDataLoaded = '已載入離線快取資料';
  static const String successCacheSync = '快取資料已同步';
  static const String successOfflineSettingsSaved = '離線設定已儲存';

  // ===== 驗證規則 =====
  static const int minMessageLength = 1;
  static const int maxMessageLength = 500;

  // ===== 資料庫SQL語句 =====
  static const String createTableMessages =
      '''
    CREATE TABLE $tableMessages (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnContent TEXT NOT NULL,
      $columnCreatedAt INTEGER NOT NULL,
      $columnUpdatedAt INTEGER
    )
  ''';

  // ===== 導航索引 =====
  static const int navIndexA = 0;
  static const int navIndexB = 1;
  static const int navIndexC = 2;

  // ===== 離線功能 =====
  static const String offlineMessage = '目前處於離線模式';
  static const String onlineMessage = '已連線至網路';

  // ===== 預設值 =====
  static const String defaultUsername = '使用者';
  static const String defaultMessage = '預設訊息';
}
