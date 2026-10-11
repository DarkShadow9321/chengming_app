# iOS 移交與上架準備

**以下所有 iOS 建置、平台插件與發行項目均「需要在 macOS / Xcode 驗證」。本次在 Windows 未完成 iOS Build 或簽章。**

## Mac 開發環境

1. 安裝與 Flutter stable 相容的 Xcode，開啟一次並由本人接受授權、安裝必要元件，確認 Command Line Tools 選定該版本。
2. 安裝 Flutter，執行 `flutter doctor -v`；Git 取得 chengming_app 專案，修改 `.vscode/settings.json` 中 Windows 工作區相鄰的 SDK 路徑。
3. `flutter pub get`、`flutter analyze`、`flutter test`。不要提交機器特定的 Generated.xcconfig 或套件快取。
4. 此 Flutter 版本預設支援 Swift Package Manager，優先讓 Flutter 工具整合插件。如果工具報告插件需 CocoaPods，依官方指南安裝 CocoaPods 並讓 Flutter 產生／安裝相應依賴；不要在 Windows 手寫 Pod lockfile 假裝已成功。
5. 以實際產生的工作區開啟 `ios/Runner.xcworkspace`，選取 Runner。確認物件、消息、收藏及版本套件在 iOS 成功整合。

## 識別與 Signing

- 現有 Bundle Identifier 為開發用 `com.example.chengmingApp`（以 Xcode Build Settings 實際值為準）；客戶需決定正式且唯一的 ID，同步 Runner 與測試 target。
- 設定 Apple Developer Team、Signing & Capabilities、憑證與 provisioning profiles。發行需要有效 Apple Developer Account，不能以 Windows 的 Android 測試替代。
- 模板 deployment target 為 iOS 15.0；確認 Xcode、Flutter 與所有套件的最低版本要求，統一 Runner／測試／插件設定。
- 顯示名稱已為「承明法拍屋」。版本來自 `pubspec.yaml` 的 version/build number，發行時递增 build number。

## Info.plist、網路與權限

- 保留預設 App Transport Security，網站使用 HTTPS，未設定 NSAllowsArbitraryLoads，沒有繞過 SSL 憑證驗證。
- 驗證 WKWebView 載入官方網站、TLS／重新導向、主要文件的網路錯誤與 HTTP 錯誤提示；外部 HTTPS 使用系統瀏覽器。
- tel／mailto 直接呼叫系統開啟。未使用 canLaunchUrl 預查，故未自行增加 LSApplicationQueriesSchemes。若未來改用 URL scheme 預查或新增特定應用程式，才依正式需求新增查詢清單。
- 本版没有接收 deep link 的 URL scheme；未來若要支援請另行設定及驗證。
- 未加入相機、照片、定位、通知、追蹤或廣告權限。未來新增功能時先確認用途、隱私說明及權限提示。
- 本版未啟用 Push Notifications capability、APNs 或 background remote notifications；Phase 2 真的需要推播時才實作。
- 檢查使用套件的 Privacy Manifest 與 Required Reason API 聲明是否隨依賴正確封裝（包含 shared_preferences 的 UserDefaults 使用）。App Store 隱私問卷必須依實際網站／插件行為填寫。
- 網站可能包含第三方內容與 Cookie；「App 沒有分析 SDK」不表示網站沒有追蹤。由客戶確認網站行為與正式政策，填入 `AppConfig.privacyPolicy`。

## 圖示與啟動畫面

- 現有 App Icon 為 Flutter 模板圖示，需客戶提供有權使用的品牌圖，替換所有要求的尺寸；檢查 1024×1024 上架圖示。
- 現有 Launch Screen 為標準模板，發行前按品牌需求更新並驗證不同 iPhone／iPad 尺寸與方向。

## iPhone 實機驗證

- 執行 `flutter devices`、`flutter run -d <iPhone ID>`，在 Xcode 設定實機 signing。
- 驗證五頁、SafeArea、瀏海／底部手勢區、橫向、Dynamic Type、鍵盤與收藏表單。
- 驗證 WebView 載入、錯誤／重試、內外連結、頁內上一頁、原生頁返回、iOS 返回手勢。
- 收藏新增／重複／移除與整個 App 關閉再開啟；本機存儲不作關鍵資料保證。
- 電話功能使用可撥號的實機驗證；模擬器無撥號能力不代表 App 故障。
- 網站的彈出視窗、第三方 iframe、Cookie、特殊連結與下載逐一檢查；本版沒有自訂下載或多視窗支援。

## TestFlight 與 App Store

1. 在 App Store Connect 建立正式 App，確認 ID、版本、類別、客戶擁有權與聯絡資料。
2. 補正式隱私政策、支援網址、品牌圖示、截圖與隱私問卷；未確認政策時不要提交。
3. `flutter build ipa` 或 Xcode Product > Archive，依當時發行要求檢查並上傳 Archive。
4. 先透過 TestFlight 由內部測試者確認功能；外部測試依 Apple 流程處理。
5. 提交審查說明，描述原生收藏與導覽的實際用途。不要以假功能保證過審；必要時依審查回饋改善。

官方參考：

- https://docs.flutter.dev/platform-integration/ios/setup
- https://docs.flutter.dev/deployment/ios
- https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers
- https://developer.apple.com/app-store/review/guidelines/
