import 'package:flutter/material.dart';

import '../models/favorite_item.dart';

class FavoriteDialog extends StatefulWidget {
  const FavoriteDialog({super.key, required this.item});
  final FavoriteItem item;
  @override
  State<FavoriteDialog> createState() => _FavoriteDialogState();
}

class _FavoriteDialogState extends State<FavoriteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item.title);
  late final _description = TextEditingController(
    text: widget.item.description,
  );

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('收藏此頁'),
    content: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              maxLength: 200,
              decoration: const InputDecoration(labelText: '標題'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? '請輸入標題'
                  : value.trim().length > 200
                  ? '標題最多 200 字'
                  : null,
            ),
            TextFormField(
              controller: _description,
              maxLength: 1000,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '備註（選填）'),
              validator: (value) =>
                  (value?.length ?? 0) > 1000 ? '備註最多 1000 字' : null,
            ),
            Text(widget.item.url, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            FavoriteItem(
              title: _name.text.trim(),
              url: widget.item.url,
              description: _description.text.trim(),
              imageUrl: widget.item.imageUrl,
              createdAt: widget.item.createdAt,
            ),
          );
        },
        child: const Text('儲存'),
      ),
    ],
  );
}
