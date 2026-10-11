import 'package:flutter/material.dart';

import '../services/favorite_service.dart';
import '../widgets/page_body.dart';
import '../widgets/website_view.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key, required this.favorites});
  final FavoriteService favorites;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: favorites,
    builder: (context, _) => PageBody(
      children: [
        Text('我的收藏', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('收藏儲存在這台裝置，移除 App 會一併刪除。'),
        if (favorites.busy) const LinearProgressIndicator(),
        if (favorites.error != null) ...[
          const SizedBox(height: 16),
          Text(favorites.error!),
          if (!favorites.ready)
            FilledButton(
              onPressed: favorites.busy ? null : favorites.load,
              child: const Text('重新讀取'),
            ),
        ],
        if (favorites.ready && favorites.items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Text('尚無收藏。瀏覽物件或消息時，按「收藏此頁」即可儲存。'),
          ),
        ...favorites.items.map(
          (item) => Card(
            child: ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(item.title),
              subtitle: Text(
                item.description.isEmpty ? item.url : item.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => WebsiteScreen(
                    url: Uri.parse(item.url),
                    title: item.title,
                    favorites: favorites,
                  ),
                ),
              ),
              trailing: IconButton(
                tooltip: '移除收藏',
                onPressed: favorites.busy
                    ? null
                    : () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('移除收藏？'),
                            content: Text(item.title),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('取消'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('移除'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          final ok = await favorites.remove(item.url);
                          if (context.mounted && !ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('移除失敗，請重試。')),
                            );
                          }
                        }
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
