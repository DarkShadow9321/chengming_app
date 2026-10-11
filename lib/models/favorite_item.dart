import '../utils/app_config.dart';

class FavoriteItem {
  const FavoriteItem({
    required this.title,
    required this.url,
    this.imageUrl,
    this.description = '',
    required this.createdAt,
  });

  final String title;
  final String url;
  final String? imageUrl;
  final String description;
  final DateTime createdAt;

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    final url = json['url'] as String;
    if (title.trim().isEmpty || !AppConfig.isInternal(Uri.parse(url))) {
      throw const FormatException('無效的收藏資料');
    }
    return FavoriteItem(
      title: title,
      url: url,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'imageUrl': imageUrl,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };
}
