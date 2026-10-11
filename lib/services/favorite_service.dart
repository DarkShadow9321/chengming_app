import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_item.dart';
import '../utils/app_config.dart';

abstract interface class FavoriteStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesFavoriteStorage implements FavoriteStorage {
  final _preferences = SharedPreferencesAsync();
  static const _key = 'favorites.v1';
  @override
  Future<String?> read() => _preferences.getString(_key);
  @override
  Future<void> write(String value) => _preferences.setString(_key, value);
}

class FavoriteService extends ChangeNotifier {
  FavoriteService(this._storage);
  final FavoriteStorage _storage;
  List<FavoriteItem> _items = [];
  bool _ready = false;
  bool _busy = false;
  String? _error;
  List<FavoriteItem> get items => List.unmodifiable(_items);
  bool get ready => _ready;
  bool get busy => _busy;
  String? get error => _error;
  bool contains(String url) => _items.any((item) => item.url == url);

  Future<void> load() async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      final raw = await _storage.read();
      final entries = raw == null
          ? <dynamic>[]
          : jsonDecode(raw) as List<dynamic>;
      final loaded = <FavoriteItem>[];
      for (final entry in entries) {
        final item = FavoriteItem.fromJson(
          Map<String, dynamic>.from(entry as Map),
        );
        if (!loaded.any((existing) => existing.url == item.url)) {
          loaded.add(item);
        }
      }
      _items = loaded;
      _ready = true;
      _error = null;
    } catch (_) {
      // 保留原始資料，不以空清單覆寫損毀或暫時讀取失敗的資料。
      _ready = false;
      _error = '無法讀取收藏。請重試；原始資料尚未變更。';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> save(FavoriteItem item) async {
    if (item.title.trim().isEmpty ||
        !AppConfig.isInternal(Uri.parse(item.url))) {
      return false;
    }
    return _persist([item, ..._items.where((old) => old.url != item.url)]);
  }

  Future<bool> remove(String url) =>
      _persist(_items.where((item) => item.url != url).toList());

  Future<bool> _persist(List<FavoriteItem> next) async {
    if (!_ready || _busy) return false;
    _busy = true;
    notifyListeners();
    try {
      await _storage.write(
        jsonEncode(next.map((item) => item.toJson()).toList()),
      );
      _items = next;
      _error = null;
      return true;
    } catch (_) {
      _error = '收藏儲存失敗，請稍後重試。';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
  // TODO: 正式 API 可提供物件 ID、title、imageUrl 與 description；
  // 現階段只存使用者選擇的頁面網址及備註，不解析網站 HTML。
}
