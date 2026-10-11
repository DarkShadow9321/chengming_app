import 'package:flutter/material.dart';

import 'app.dart';
import 'services/favorite_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChengmingApp(favorites: FavoriteService(PreferencesFavoriteStorage())),
  );
}
