# Phase 1 驗證與變更紀錄

日期：2026-10-03（Asia/Taipei）。Windows 11，Flutter stable 3.47.6，Dart 3.13.5。

## 實際結果

| 檢查 | 最終結果 |
| --- | --- |
| flutter pub get | 成功，產生 pubspec.lock |
| dart format lib test | 18 個 Dart 檔案完成格式化 |
| flutter analyze | No issues found!（最後一輪 13.6 秒） |
| flutter test | All tests passed!，9 個測試（最後一輪約 4 秒） |
| flutter doctor -v | 找不到 Android SDK；沒有 Android 裝置；Flutter 不在系統 PATH |
| Android APK／實機 | 未執行；依使用者要求提供環境設定步驟，未安裝 Android SDK／新版 JDK |
| iOS Build／實機 | 未執行；需要在 macOS / Xcode 驗證 |

最初含中文路徑的 analyze 失敗，原因為 Flutter 工具的 LSP Content-Length 計算。改以暫時的 V: 磁碟映射同一工作區後成功；SDK 原始碼未修改。第一輪修正 WebView HTTP request API 欄位用法及 lint，表格為修正後结果。

## 測試內容與限制

- favorite_service_test.dart：服務重新建立後保留欄位、同網址更新／去重、移除後不再載入、儲存失敗保留原資料、讀取失敗／損毀不覆寫。
- link_policy_test.dart：本站及外部 HTTPS、tel、mailto，以及 HTTP／JavaScript／file／intent／含帳密 URI 的拒絕規則。
- widget_test.dart：320×640、390×844、800×600 的五頁導覽、無佈局例外、收藏空狀態與返回原生首頁。
- favorite_dialog_test.dart：空白標題驗證、修改標題、保留備註／建立時間、關閉後沒有資源釋放例外。

儲存及版本資訊使用替身；不代表已驗證原生 WebView 或 SharedPreferences 平台儲存。TLS、網路錯誤、HTTP 回呼、網頁歷史返回、外部應用程式、iframe、特殊連結及裝置重啟收藏仍需依 README 清單測試。

## 新增檔案

根目錄新增 `.gitignore`，只排除 `.tools/`。其餘 App 檔案均在新資料夾 chengming_app/。

```text
lib/main.dart
lib/app.dart
lib/screens/home_screen.dart
lib/screens/property_screen.dart
lib/screens/news_screen.dart
lib/screens/favorite_screen.dart
lib/screens/more_screen.dart
lib/models/favorite_item.dart
lib/services/favorite_service.dart
lib/services/webview_service.dart
lib/utils/app_config.dart
lib/widgets/page_body.dart
lib/widgets/website_view.dart
lib/widgets/favorite_dialog.dart
```

另新增上述四個 test 檔、README.md、IOS_SETUP.md、VALIDATION.md、`.vscode/settings.json`、`.vscode/launch.json`。

Flutter create 產生標準 android/、ios/、analysis_options.yaml、pubspec.yaml、.metadata、專案 .gitignore、平台圖示、啟動畫面等檔案。保留平台結構。

## 新模板內調整的檔案

- pubspec.yaml：App 描述、四個執行期插件；pubspec.lock 鎖定解析結果。
- android/app/src/main/AndroidManifest.xml：中文名稱、INTERNET 權限、禁止明文流量。
- android/app/build.gradle.kts：確保最低 Android API 24。
- ios/Runner/Info.plist：中文名稱，未放寬 ATS。
- README.md：改為本專案文件。
- test/widget_test.dart：計數器樣板測試改成實際導覽測試。

既有 RWDtest.html、medicine-app、其他 HTML／Python 專案與原 `.vscode` 未修改。初始 git status 已顯示 `.gitattributes`、HW1.html 的刪除，本次未变更或還原。

## 套件解析結果

| 直接插件 | 安裝版本 | 用途 |
| --- | --- | --- |
| webview_flutter | 4.14.1 | Android WebView／iOS WKWebView |
| shared_preferences | 2.5.5 | SharedPreferencesAsync 本機收藏 JSON |
| url_launcher | 6.3.3 | 瀏覽器／電話／電子郵件 |
| package_info_plus | 10.2.2 | 安裝版本與 build number |

flutter_test 為 SDK 內建；flutter_lints 6.0.0 為開發期 lint。傳遞依賴詳見 pubspec.lock。

## 尚待完成

- Android SDK、相容 JDK、裝置／模擬器設定及 APK／實機測試；依使用者選擇提供步驟。
- 客戶正式隱私政策與品牌圖示；目前為明確標示的開發版說明及 Flutter 模板圖示。
- 正式 Android applicationId／release signing、iOS Bundle ID／signing、TestFlight／App Store 發行。
- API、物件圖片、進階搜尋、會員、推播、分享與雲端同步不在本次範圍。本機頁面收藏已可使用。
- Mac 工作詳見 IOS_SETUP.md。Phase 2 建議先補實機測試與正式政策，再與網站維護者確認真正的物件資料來源。
