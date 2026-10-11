import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/favorite_service.dart';
import '../services/webview_service.dart';
import '../utils/app_config.dart';
import '../widgets/page_body.dart';
import '../widgets/website_view.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key, required this.favorites});
  final FavoriteService favorites;
  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();
  Future<void> _open(Uri uri) async {
    final ok = await WebviewService.openExternal(uri);
    if (mounted && !ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('無法開啟連結，請確認裝置支援此操作。')));
    }
  }

  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      ListTile(
        leading: const Icon(Icons.business_outlined),
        title: const Text('公司介紹'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WebsiteScreen(
              url: AppConfig.about,
              title: '公司介紹',
              favorites: widget.favorites,
            ),
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.language),
        title: const Text('官方網站'),
        subtitle: Text(AppConfig.website.host),
        onTap: () => _open(AppConfig.website),
      ),
      ListTile(
        leading: const Icon(Icons.phone_outlined),
        title: const Text('聯絡我們'),
        subtitle: const Text(AppConfig.phoneLabel),
        onTap: () => _open(AppConfig.phone),
      ),
      ListTile(
        leading: const Icon(Icons.privacy_tip_outlined),
        title: const Text('隱私權政策'),
        onTap: () {
          final uri = AppConfig.privacyPolicy;
          if (uri != null) {
            _open(uri);
            return;
          }
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('資料使用說明（開發版本）'),
              content: const SingleChildScrollView(
                child: Text(
                  '本版本的收藏只儲存在本機，沒有加入廣告、分析或追蹤 SDK。\n\n'
                  '瀏覽網站時會連線到官方網站；網站可能使用 Cookie 或載入第三方內容。\n\n'
                  '客戶尚未提供正式隱私權政策，需於正式發布前補齊。此說明不替代正式政策。',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('關閉'),
                ),
              ],
            ),
          );
        },
      ),
      FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) => ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('App 版本'),
          subtitle: Text(
            snapshot.hasData
                ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                : snapshot.hasError
                ? '無法取得版本資訊'
                : '讀取中…',
          ),
        ),
      ),
    ],
  );
}
