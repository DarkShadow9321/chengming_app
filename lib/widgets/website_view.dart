import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/favorite_item.dart';
import '../services/favorite_service.dart';
import '../services/webview_service.dart';
import '../utils/app_config.dart';
import 'favorite_dialog.dart';

class WebsiteView extends StatefulWidget {
  const WebsiteView({
    super.key,
    required this.initialUrl,
    required this.title,
    required this.favorites,
    this.active = true,
    required this.onHistoryChanged,
  });
  final Uri initialUrl;
  final String title;
  final FavoriteService favorites;
  final bool active;
  final ValueChanged<bool> onHistoryChanged;
  @override
  State<WebsiteView> createState() => WebsiteViewState();
}

class WebsiteViewState extends State<WebsiteView> {
  WebViewController? _controller;
  int _progress = 0;
  bool _canGoBack = false;
  bool _saving = false;
  bool _pageReady = false;
  String? _error;
  Timer? _loadTimer;
  late Uri _currentUrl;
  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    if (widget.active) _initialize();
  }

  @override
  void didUpdateWidget(covariant WebsiteView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && _controller == null) _initialize();
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _initialize() async {
    if (!_supported) return;
    try {
      final controller = WebViewController();
      _controller = controller;
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value);
          },
          onPageStarted: (url) {
            if (!mounted) return;
            final uri = Uri.tryParse(url);
            setState(() {
              if (uri != null && AppConfig.isInternal(uri)) _currentUrl = uri;
              _pageReady = false;
              _error = null;
              _progress = 0;
            });
            _startTimeout();
            _updateHistory();
          },
          onPageFinished: (url) async {
            if (!mounted) return;
            _loadTimer?.cancel();
            final uri = Uri.tryParse(url);
            setState(() {
              if (uri != null && AppConfig.isInternal(uri)) _currentUrl = uri;
              _progress = 100;
              _pageReady = _error == null;
            });
            await _updateHistory();
          },
          onUrlChange: (change) {
            final uri = Uri.tryParse(change.url ?? '');
            if (mounted && uri != null && AppConfig.isInternal(uri)) {
              setState(() => _currentUrl = uri);
              _updateHistory();
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              _showError('網頁無法載入。請確認網路連線後重試。');
            }
          },
          onHttpError: (error) {
            // 跨平台 HTTP request 僅提供 uri；忽略圖片／iframe 的錯誤。
            if (error.request?.uri == _currentUrl) {
              _showError('網站暫時無法提供此頁面，請稍後重試。');
            }
          },
          onNavigationRequest: (request) async {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            final target = WebviewService.target(uri);
            if (target == LinkTarget.internal) {
              return NavigationDecision.navigate;
            }
            // iframe 不觸發外部應用程式，也不載入非本站內容。
            if (request.isMainFrame && target == LinkTarget.external) {
              if (!await WebviewService.openExternal(uri)) {
                _message('無法開啟此連結，請確認已安裝對應的應用程式。');
              }
            } else if (request.isMainFrame) {
              _message('此連結不支援或不是安全的 HTTPS 網址。');
            }
            return NavigationDecision.prevent;
          },
        ),
      );
      if (mounted) await _load(widget.initialUrl);
    } catch (_) {
      _showError('無法啟動網頁元件，請重新開啟 App。');
    }
  }

  void _showError(String error) {
    _loadTimer?.cancel();
    if (mounted) {
      setState(() {
        _error = error;
        _pageReady = false;
        _progress = 100;
      });
    }
  }

  void _startTimeout() {
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(seconds: 30), () {
      _showError('網頁載入逾時，請確認網路後重試。');
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  Future<void> _load(Uri uri) async {
    if (!AppConfig.isInternal(uri)) return;
    if (mounted) {
      setState(() {
        _currentUrl = uri;
        _error = null;
        _progress = 0;
        _pageReady = false;
      });
    }
    _startTimeout();
    try {
      await _controller?.loadRequest(uri);
    } catch (_) {
      _showError('網頁載入失敗，請重試。');
    }
  }

  Future<void> _updateHistory() async {
    try {
      final value = await _controller?.canGoBack() ?? false;
      if (!mounted) return;
      setState(() => _canGoBack = value);
      widget.onHistoryChanged(value);
    } catch (_) {
      /* 元件可能在離開頁面時停止。 */
    }
  }

  Future<bool> goBack() async {
    try {
      if (await _controller?.canGoBack() ?? false) {
        await _controller!.goBack();
        await _updateHistory();
        return true;
      }
    } catch (_) {
      _message('無法返回網頁，請重試。');
      return true;
    }
    return false;
  }

  Future<void> _savePage() async {
    if (_saving || !_pageReady) return;
    setState(() => _saving = true);
    final pageUrl = _currentUrl.toString();
    try {
      final pageTitle = await _controller?.getTitle();
      if (!mounted) return;
      if (pageUrl != _currentUrl.toString() || !_pageReady) {
        _message('頁面已變更，請在載入完成後重新收藏。');
        return;
      }
      FavoriteItem? existing;
      for (final item in widget.favorites.items) {
        if (item.url == pageUrl) {
          existing = item;
          break;
        }
      }
      final item = await showDialog<FavoriteItem>(
        context: context,
        builder: (context) => FavoriteDialog(
          item:
              existing ??
              FavoriteItem(
                title: pageTitle?.trim().isNotEmpty == true
                    ? pageTitle!
                    : widget.title,
                url: pageUrl,
                createdAt: DateTime.now(),
              ),
        ),
      );
      if (item == null || !mounted) return;
      final ok = await widget.favorites.save(item);
      _message(ok ? '已儲存收藏' : '無法儲存收藏，請至收藏頁確認狀態。');
    } catch (_) {
      _message('無法取得頁面資訊，請重試。');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('內嵌網頁支援 Android 與 iOS。請使用手機或 Android 模擬器測試。'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!await WebviewService.openExternal(widget.initialUrl)) {
                    _message('無法開啟瀏覽器。');
                  }
                },
                child: const Text('以瀏覽器開啟'),
              ),
            ],
          ),
        ),
      );
    }
    if (_controller == null && _error == null) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                tooltip: '上一頁',
                onPressed: _canGoBack ? goBack : null,
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton(
                tooltip: '重新載入',
                onPressed: () => _load(_currentUrl),
                icon: const Icon(Icons.refresh),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.favorites,
                  builder: (context, _) => TextButton.icon(
                    onPressed:
                        _pageReady &&
                            !_saving &&
                            widget.favorites.ready &&
                            !widget.favorites.busy
                        ? _savePage
                        : null,
                    icon: Icon(
                      widget.favorites.contains(_currentUrl.toString())
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                    ),
                    label: const Text('收藏此頁'),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_progress < 100)
          LinearProgressIndicator(
            value: _progress == 0 ? null : _progress / 100,
          ),
        Expanded(
          child: _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off, size: 48),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => _load(_currentUrl),
                          child: const Text('重試'),
                        ),
                      ],
                    ),
                  ),
                )
              : WebViewWidget(controller: _controller!),
        ),
      ],
    );
  }
}

class WebsiteScreen extends StatefulWidget {
  const WebsiteScreen({
    super.key,
    required this.url,
    required this.title,
    required this.favorites,
  });
  final Uri url;
  final String title;
  final FavoriteService favorites;
  @override
  State<WebsiteScreen> createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
  final _key = GlobalKey<WebsiteViewState>();
  bool _hasHistory = false;
  Future<void> _back() async {
    if (await _key.currentState?.goBack() ?? false) return;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_hasHistory,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
          tooltip: '返回',
        ),
      ),
      body: SafeArea(
        child: WebsiteView(
          key: _key,
          initialUrl: widget.url,
          title: widget.title,
          favorites: widget.favorites,
          onHistoryChanged: (value) {
            if (mounted) setState(() => _hasHistory = value);
          },
        ),
      ),
    ),
  );
}
