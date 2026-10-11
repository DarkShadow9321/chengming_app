import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:chengming_app/app.dart';
import 'package:chengming_app/services/favorite_service.dart';

class MemoryStorage implements FavoriteStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

void main() {
  setUp(
    () => PackageInfo.setMockInitialValues(
      appName: '承明法拍屋',
      packageName: 'com.example.chengming_app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    ),
  );

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(800, 600),
  ]) {
    testWidgets('五頁導覽與小螢幕佈局 $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final favorites = FavoriteService(MemoryStorage());
      await tester.pumpWidget(ChengmingApp(favorites: favorites));
      await tester.pumpAndSettle();
      expect(find.text('找房，從這裡開始'), findsOneWidget);
      for (final label in ['法拍物件', '最新消息', '收藏', '更多', '首頁']) {
        final destination = find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        );
        await tester.tap(destination);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('收藏'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('尚無收藏'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('找房，從這裡開始'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      favorites.dispose();
    });
  }
}
