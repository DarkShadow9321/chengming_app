import 'package:flutter/material.dart';

import '../services/favorite_service.dart';
import '../utils/app_config.dart';
import '../widgets/website_view.dart';

class PropertyScreen extends StatelessWidget {
  const PropertyScreen({
    super.key,
    required this.favorites,
    required this.active,
    required this.onHistoryChanged,
    required this.viewKey,
  });
  final FavoriteService favorites;
  final bool active;
  final ValueChanged<bool> onHistoryChanged;
  final GlobalKey<WebsiteViewState> viewKey;
  @override
  Widget build(BuildContext context) => WebsiteView(
    key: viewKey,
    initialUrl: AppConfig.properties,
    title: '法拍物件',
    favorites: favorites,
    active: active,
    onHistoryChanged: onHistoryChanged,
  );
}
