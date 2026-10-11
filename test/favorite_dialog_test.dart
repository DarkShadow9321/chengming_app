import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chengming_app/models/favorite_item.dart';
import 'package:chengming_app/widgets/favorite_dialog.dart';

void main() {
  testWidgets('收藏表單驗證標題、保留備註與建立時間，關閉後正確釋放', (tester) async {
    final original = FavoriteItem(
      title: '原標題',
      url: 'https://www.s41349.com/case/test',
      description: '原備註',
      createdAt: DateTime.utc(2026, 10, 3),
    );
    FavoriteItem? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDialog<FavoriteItem>(
                  context: context,
                  builder: (_) => FavoriteDialog(item: original),
                );
              },
              child: const Text('開啟收藏'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('開啟收藏'));
    await tester.pumpAndSettle();
    expect(find.text('原備註'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '   ');
    await tester.tap(find.text('儲存'));
    await tester.pumpAndSettle();
    expect(find.text('請輸入標題'), findsOneWidget);
    expect(result, isNull);
    await tester.enterText(find.byType(TextFormField).first, ' 更新標題 ');
    await tester.tap(find.text('儲存'));
    await tester.pumpAndSettle();
    expect(result!.title, '更新標題');
    expect(result!.description, original.description);
    expect(result!.createdAt, original.createdAt);
    expect(tester.takeException(), isNull);
  });
}
