# 承明法拍屋 Flutter App

Phase 1：Material 3 原生首頁、五頁導覽、本機收藏與更多頁面；物件及消息內容沿用官方網站的 WebView。沒有假設存在 API，也沒有 HTML scraping、會員、推播、廣告或分析 SDK。

完整功能、操作流程、技術架構與待完成項目見 [功能統整（FEATURES.md）](FEATURES.md)。

## 開發環境與初始檢查

原工作區包含 HTML、Vue（medicine-app）及 Python 等專案，沒有 pubspec.yaml 或 Flutter 專案。原有檔案保留。本專案獨立位於 chengming_app/，包含 android/ 與 ios/。

建立時使用 Windows、VS Code、Flutter stable 3.47.6、Dart 3.13.5、Git。官方 Flutter SDK 下載於工作區 `.tools/flutter`，套件快取在 `.tools/pub-cache`，由根目錄 `.gitignore` 排除。未修改系統 PATH。

用 VS Code 開啟 **chengming_app 資料夾**，安裝 Flutter／Dart 擴充套件；本專案的 `.vscode/settings.json` 已指定相鄰 SDK。若把專案單獨搬走，請修改或移除這個本機 SDK 設定，改用新電腦的 SDK。

## 執行與檢查

在 chengming_app/ 的 PowerShell 執行，僅設定目前終端機：

```powershell
$env:PATH = (Resolve-Path '../.tools/flutter/bin').Path + ';' + $env:PATH
$env:PUB_CACHE = [System.IO.Path]::GetFullPath((Join-Path $PWD '../.tools/pub-cache'))
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d <Android裝置ID>
```

若 Flutter 已安裝並在 PATH 中，直接使用 `flutter pub get`、`flutter run` 即可。App 只產生 Android／iOS 平台專案；Windows 是開發主機，不是此版本的桌面 App 執行目標。

### 中文路徑的分析工具問題

此次下載的 Flutter 3.47.6 在 `flutter analyze` 的 LSP 傳送程式以字元數計算 Content-Length；工作區路徑含「桌面」時分析伺服器會出現 JSON `Unexpected end of input`。這是本機 SDK 工具問題，沒有修改 SDK 或搬動專案。可先將同一資料夾暫時映射至空閒的英文字母磁碟，再執行：

```powershell
# 在原工作區根目錄執行；先確認 V: 未被使用。
subst V: "$PWD"
Set-Location V:\chengming_app
$env:PUB_CACHE = 'V:\.tools\pub-cache'
& V:\.tools\flutter\bin\flutter.bat pub get
& V:\.tools\flutter\bin\flutter.bat analyze
& V:\.tools\flutter\bin\flutter.bat test
# 回到原本路徑後移除映射；不要在 V: 上執行移除。
# subst V: /D
```

或者在不含中文的路徑使用官方 SDK 與專案。SDK 更新後可重新確認是否仍需此處理。

## 專案架構

```text
lib/
  main.dart                  啟動與本機儲存初始化
  app.dart                   主題、Scaffold、五頁導覽與返回處理
  screens/                   首頁、物件、消息、收藏、更多
  widgets/website_view.dart   共用 WebView 與獨立網站頁
  widgets/page_body.dart      可捲動、限制最大寬度的原生頁面
  widgets/favorite_dialog.dart  收藏標題與備註表單
  models/favorite_item.dart   收藏欄位與 JSON 轉換
  services/favorite_service.dart  收藏載入、去重與持久化
  services/webview_service.dart   網址分類與外部開啟
  utils/app_config.dart       官方網址、電話及待確認設定
test/                        收藏、網址規則、導覽與螢幕尺寸測試
android/                     Android 平台專案
ios/                         iOS 平台專案
```

## 套件

| 套件 | 用途 |
| --- | --- |
| webview_flutter | 官方 WebView；Android 系統 WebView、iOS WKWebView |
| shared_preferences | SharedPreferencesAsync 儲存收藏 JSON；適合非關鍵本機收藏 |
| url_launcher | 外部 HTTPS 網址、電話及電子郵件交給系統應用程式 |
| package_info_plus | 顯示安裝版本與 build number |
| flutter_lints | 官方程式碼規則（開發依賴） |

版本以 `pubspec.lock` 的解析結果為準，各功能套件均支援 Android 與 iOS。

## 已實作功能與操作

- 首頁提供物件、消息及收藏入口；五頁 NavigationBar 保留頁面狀態。
- 物件 `/case`、消息 `/news`、介紹 `/about` 使用已確認的官方網址；WebView 在第一次選到該分頁時啟動。
- 網頁載入進度、主要文件網路／HTTP 錯誤、30 秒逾時、重試、上一頁。
- Android 返回鍵先走網站歷史；沒有歷史時回原生首頁，首頁再返回由系統離開 App。收藏或公司介紹的獨立網頁先走網站歷史，再關閉該頁。
- 本站 HTTPS 在 App 內瀏覽；外部 HTTPS、tel、mailto 交由系統處理；拒絕 HTTP、JavaScript、file、intent 等頂層連結。沒有 SSL 憑證繞過，Android 明確禁止明文流量，iOS 使用預設 ATS。
- 網頁載入完成後按「收藏此頁」，確認標題並填寫備註。原生收藏頁可重新開啟或確認移除；同網址再次收藏會更新資料。
- 收藏預留 title、url、imageUrl、description、createdAt。沒有物件 API，因此 imageUrl 不自動抓取；TODO 記錄正式資料介面的整合位置。
- 儲存失敗不更新記憶體清單；讀取失敗／資料損毀不覆寫原始資料。收藏在一般關閉及重新開啟後保留；移除 App 會刪除本機資料，沒有雲端同步或交易級備份保證。
- 更多包含公司介紹、官網、官方電話、隱私權政策入口及實際版本。
- 正式隱私權政策尚未提供：`AppConfig.privacyPolicy` 為 null，開發版顯示明確標示的資料說明，**正式發布前必須提供客戶確認的政策**。

官網來源：https://www.s41349.com/ ，物件：https://www.s41349.com/case ，消息：https://www.s41349.com/news ，介紹：https://www.s41349.com/about 。沒有複製網站物件資料或圖片至 App。

## Android：Windows 設定與測試

目前 `flutter doctor -v` 找不到 Android SDK；只偵測到舊 Java 11，未連接 Android 裝置。依使用者選擇，本次沒有安裝 Android SDK／新版 JDK，也沒有執行 APK 建置或 Android 實機測試。

1. 從 https://developer.android.com/studio 安裝 Android Studio（也可繼續以 VS Code 寫程式）。
2. 在 SDK Manager 安裝 Android SDK Platform API 36、相容的 Build Tools、Platform Tools、Command-line Tools。此 Flutter 模板使用 compileSdk 36、NDK 28.2.13676358；按建置需求安裝該 NDK。
3. 使用相容的 JDK（建議 Android Studio 內附的 JBR／JDK 21）。目前 Gradle 9.3.1、Android Gradle Plugin 9.1.0，不應沿用舊 Java 11。
4. 以實際路徑設定 `flutter config --android-sdk <SDK路徑>` 和 `flutter config --jdk-dir <JDK路徑>`。
5. 執行 `flutter doctor --android-licenses`，親自閱讀並確認授權條款，再執行 `flutter doctor -v`。
6. 連接開啟 USB 偵錯的 Android 手機並允許電腦，或使用 Device Manager 建立／啟動模擬器。此專案最低 Android API 24。
7. `flutter devices` 後執行 `flutter run -d <裝置ID>`；可用 `flutter build apk --debug` 建立測試 APK。

若 Gradle／Android 工具不接受中文工作區路徑，可使用上述暫時磁碟映射或選擇不含中文的開發路徑。Android applicationId 現為開發用 `com.example.chengming_app`；發布前需改為客戶持有的正式 ID，並設定正式簽章。模板 release 仍使用 debug signing，不能直接作為正式發行設定。

手機手動驗證：

- 首次啟動、五頁切換、窄螢幕／旋轉／放大字型。
- 物件及消息載入、內部連結、返回鍵多層網頁歷史。
- 外部網址、電話、網站重新導向；電話需支援撥號的裝置。
- 關閉網路時載入失敗／重試，HTTP 錯誤頁與重新恢復網路。
- 收藏、重複收藏、取消對話框、移除；完整關閉再開啟確認保留。
- 正式網站的第三方 iframe、彈出視窗、下載及特殊連結需要實機確認；本版沒有下載或多視窗管理功能。

## iOS

保留完整 ios/ 平台結構，模板 deployment target 為 iOS 15.0。Windows 無法完成最終 iOS Build、簽章、WKWebView 實機測試或 TestFlight。需要 macOS、Xcode、Apple Developer Account，詳見 [IOS_SETUP.md](IOS_SETUP.md)。

## 驗證結果與 Phase 2

此次實際檢查結果記錄於 [VALIDATION.md](VALIDATION.md)。自動化測試使用可注入的記憶體儲存替身，不代表已驗證 Android／iOS 原生儲存或 WebView。必須補做上述手機驗證。

Phase 2 建議先補 Android 實機與 iPhone 測試、正式隱私政策與品牌圖示，再與網站維護者確認是否提供官方物件 API；若有，加入真正的物件 ID、圖片、詳細資料及搜尋。分享、使用者偏好、物件追蹤與推播可依需求逐步加入。

App Store 審查仍由 Apple 決定；原生收藏及導覽不保證過審。應依實際使用價值和最新審查規範準備發布。
