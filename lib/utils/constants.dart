/// HelloWorld應用程式常數定義
class Constants {
  // 防止實例化
  Constants._();

  // === 應用程式基本資訊 ===
  static const String APP_NAME = 'HelloWorld';
  static const String APP_VERSION = '1.0.0';

  // === 資料庫相關常數 ===
  static const String DATABASE_NAME = 'hello_world.db';
  static const int DATABASE_VERSION = 1;

  // 資料表名稱
  static const String TABLE_MESSAGES = 'messages';

  // Messages資料表欄位
  static const String COLUMN_ID = 'id';
  static const String COLUMN_CONTENT = 'content';
  static const String COLUMN_CREATED_AT = 'created_at';
  static const String COLUMN_UPDATED_AT = 'updated_at';

  // === API相關常數 ===
  static const String TIME_API_BASE_URL = 'http://worldtimeapi.org/api';
  static const String TIME_API_TIMEZONE = 'timezone/Asia/Taipei';
  static const String TIME_API_FULL_URL = '$TIME_API_BASE_URL/$TIME_API_TIMEZONE';

  // API請求逾時時間（秒）
  static const int API_TIMEOUT_SECONDS = 30;

  // === UI相關常數 ===
  // 間距
  static const double SPACING_SMALL = 8.0;
  static const double SPACING_MEDIUM = 16.0;
  static const double SPACING_LARGE = 24.0;
  static const double SPACING_EXTRA_LARGE = 32.0;

  // 圓角半徑
  static const double BORDER_RADIUS_SMALL = 4.0;
  static const double BORDER_RADIUS_MEDIUM = 8.0;
  static const double BORDER_RADIUS_LARGE = 12.0;

  // 字體大小
  static const double FONT_SIZE_SMALL = 12.0;
  static const double FONT_SIZE_MEDIUM = 16.0;
  static const double FONT_SIZE_LARGE = 20.0;
  static const double FONT_SIZE_EXTRA_LARGE = 24.0;

  // 圖標大小
  static const double ICON_SIZE_SMALL = 16.0;
  static const double ICON_SIZE_MEDIUM = 24.0;
  static const double ICON_SIZE_LARGE = 32.0;
  static const double ICON_SIZE_EXTRA_LARGE = 48.0;

  // === 頁面標識 ===
  static const String PAGE_LOGIN = 'login';
  static const String PAGE_MAIN = 'main';
  static const String PAGE_A = 'pageA';
  static const String PAGE_A1 = 'pageA1';
  static const String PAGE_A2 = 'pageA2';
  static const String PAGE_B = 'pageB';
  static const String PAGE_C = 'pageC';

  // === 本地存儲Key ===
  static const String PREF_FIRST_RUN = 'first_run';
  static const String PREF_USER_NAME = 'user_name';
  static const String PREF_LAST_TIME_DATA = 'last_time_data';
  static const String PREF_OFFLINE_SETTINGS = 'offline_settings';
  static const String PREF_API_HISTORY = 'api_history';
  static const String PREF_OFFLINE_QUEUE = 'offline_queue';
  static const String PREF_NETWORK_HISTORY = 'network_history';

  // === 錯誤訊息 ===
  static const String ERROR_NETWORK = '網路連線錯誤，請檢查網路設定';
  static const String ERROR_DATABASE = '資料庫操作錯誤';
  static const String ERROR_API = 'API呼叫失敗';
  static const String ERROR_VALIDATION = '輸入資料格式錯誤';
  static const String ERROR_UNKNOWN = '發生未知錯誤';

  // === 成功訊息 ===
  static const String SUCCESS_MESSAGE_SAVED = '訊息已成功儲存';
  static const String SUCCESS_MESSAGE_UPDATED = '訊息已成功更新';
  static const String SUCCESS_MESSAGE_DELETED = '訊息已成功刪除';
  static const String SUCCESS_TIME_FETCHED = '時間資料已成功取得';
  static const String SUCCESS_OFFLINE_DATA_LOADED = '已載入離線快取資料';
  static const String SUCCESS_CACHE_SYNC = '快取資料已同步';
  static const String SUCCESS_OFFLINE_SETTINGS_SAVED = '離線設定已儲存';

  // === 驗證規則 ===
  static const int MIN_MESSAGE_LENGTH = 1;
  static const int MAX_MESSAGE_LENGTH = 500;

  // === 資料庫SQL語句 ===
  static const String CREATE_TABLE_MESSAGES = '''
    CREATE TABLE $TABLE_MESSAGES (
      $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
      $COLUMN_CONTENT TEXT NOT NULL,
      $COLUMN_CREATED_AT INTEGER NOT NULL,
      $COLUMN_UPDATED_AT INTEGER
    )
  ''';

  // === 導航索引 ===
  static const int NAV_INDEX_A = 0;
  static const int NAV_INDEX_B = 1;
  static const int NAV_INDEX_C = 2;

  // === 離線功能 ===
  static const String OFFLINE_MESSAGE = '目前處於離線模式';
  static const String ONLINE_MESSAGE = '已連線至網路';

  // === 預設值 ===
  static const String DEFAULT_USERNAME = '使用者';
  static const String DEFAULT_MESSAGE = '預設訊息';
} 