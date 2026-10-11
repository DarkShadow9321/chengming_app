import 'package:flutter/material.dart';

import '../widgets/page_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSelect});
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Icon(
        Icons.home_work_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 16),
      Text('找房，從這裡開始', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      const Text('瀏覽法拍物件與最新消息，將感興趣的頁面收藏，方便下次查看。'),
      const SizedBox(height: 24),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('法拍物件', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('沿用官方網站的物件查詢，查看目前刊登的內容。'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => onSelect(1),
                icon: const Icon(Icons.search),
                label: const Text('瀏覽物件'),
              ),
            ],
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.article_outlined),
        title: const Text('最新消息'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onSelect(2),
      ),
      ListTile(
        leading: const Icon(Icons.bookmark_outline),
        title: const Text('我的收藏'),
        subtitle: const Text('查看儲存在本機的頁面與備註'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onSelect(3),
      ),
      const SizedBox(height: 24),
      const Text(
        '網站物件資訊可能更新，收藏只保留連結與備註。',
        style: TextStyle(color: Colors.black54),
      ),
    ],
  );
}
