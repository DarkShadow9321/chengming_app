import 'package:flutter_test/flutter_test.dart';
import 'package:chengming_app/models/favorite_item.dart';
import 'package:chengming_app/services/favorite_service.dart';

class MemoryStorage implements FavoriteStorage {
  String? value;
  bool failRead = false;
  bool failWrite = false;
  @override
  Future<String?> read() async {
    if (failRead) throw StateError('read failed');
    return value;
  }

  @override
  Future<void> write(String value) async {
    if (failWrite) throw StateError('write failed');
    this.value = value;
  }
}

FavoriteItem item({String title = '測試物件'}) => FavoriteItem(
  title: title,
  url: 'https://www.s41349.com/case/test',
  imageUrl: 'https://www.s41349.com/image/test.jpg',
  description: '使用者備註',
  createdAt: DateTime.utc(2026, 10, 3),
);

void main() {
  test('收藏重啟後保留所有欄位，重複網址更新，移除後保留刪除結果', () async {
    final storage = MemoryStorage();
    final first = FavoriteService(storage);
    await first.load();
    expect(await first.save(item()), isTrue);
    final restarted = FavoriteService(storage);
    await restarted.load();
    expect(restarted.items.single.toJson(), item().toJson());
    expect(await restarted.save(item(title: '更新標題')), isTrue);
    expect(restarted.items.length, 1);
    expect(restarted.items.single.title, '更新標題');
    expect(await restarted.remove(item().url), isTrue);
    final afterRemove = FavoriteService(storage);
    await afterRemove.load();
    expect(afterRemove.items, isEmpty);
  });

  test('寫入失敗不讓畫面顯示尚未儲存的變更，並可重試', () async {
    final storage = MemoryStorage();
    final service = FavoriteService(storage);
    await service.load();
    await service.save(item());
    final before = storage.value;
    storage.failWrite = true;
    expect(await service.remove(item().url), isFalse);
    expect(service.items.length, 1);
    expect(storage.value, before);
    expect(service.error, isNotNull);
    storage.failWrite = false;
    expect(await service.remove(item().url), isTrue);
    expect(service.error, isNull);
  });

  test('讀取失敗或資料損毀不覆寫原始收藏', () async {
    final storage = MemoryStorage()..value = 'invalid json';
    final service = FavoriteService(storage);
    await service.load();
    expect(service.ready, isFalse);
    expect(await service.save(item()), isFalse);
    expect(storage.value, 'invalid json');
    storage.value = null;
    await service.load();
    expect(service.ready, isTrue);
    storage.failRead = true;
    await service.load();
    expect(service.ready, isFalse);
    expect(service.error, isNotNull);
  });
}
