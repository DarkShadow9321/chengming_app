import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/property_screen.dart';
import 'screens/news_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/more_screen.dart';
import 'services/favorite_service.dart';
import 'utils/app_config.dart';
import 'widgets/website_view.dart';

class ChengmingApp extends StatelessWidget {
  const ChengmingApp({super.key, required this.favorites});
  final FavoriteService favorites;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppConfig.appName,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff245c4d)),
      scaffoldBackgroundColor: const Color(0xfff6f7f4),
    ),
    home: _AppShell(favorites: favorites),
  );
}

class _AppShell extends StatefulWidget {
  const _AppShell({required this.favorites});
  final FavoriteService favorites;
  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _index = 0;
  final _propertyKey = GlobalKey<WebsiteViewState>();
  final _newsKey = GlobalKey<WebsiteViewState>();
  @override
  void initState() {
    super.initState();
    widget.favorites.load();
  }

  void _select(int index) => setState(() => _index = index);
  Future<void> _back() async {
    final state = _index == 1
        ? _propertyKey.currentState
        : _index == 2
        ? _newsKey.currentState
        : null;
    if (await state?.goBack() ?? false) return;
    if (mounted) _select(0);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _index == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: Scaffold(
      appBar: AppBar(title: const Text(AppConfig.appName)),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onSelect: _select),
            PropertyScreen(
              favorites: widget.favorites,
              active: _index == 1,
              viewKey: _propertyKey,
              onHistoryChanged: (_) {},
            ),
            NewsScreen(
              favorites: widget.favorites,
              active: _index == 2,
              viewKey: _newsKey,
              onHistoryChanged: (_) {},
            ),
            FavoriteScreen(favorites: widget.favorites),
            MoreScreen(favorites: widget.favorites),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首頁',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_work_outlined),
            selectedIcon: Icon(Icons.home_work),
            label: '法拍物件',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: '最新消息',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: '收藏',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: '更多'),
        ],
      ),
    ),
  );
}
