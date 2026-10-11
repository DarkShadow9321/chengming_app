import 'package:url_launcher/url_launcher.dart';

import '../utils/app_config.dart';

enum LinkTarget { internal, external, blocked }

class WebviewService {
  static LinkTarget target(Uri uri) {
    if (AppConfig.isInternal(uri)) return LinkTarget.internal;
    if (uri.userInfo.isNotEmpty) return LinkTarget.blocked;
    if (uri.scheme == 'https' && uri.host.isNotEmpty ||
        uri.scheme == 'tel' ||
        uri.scheme == 'mailto') {
      return LinkTarget.external;
    }
    return LinkTarget.blocked;
  }

  static Future<bool> openExternal(Uri uri) async {
    if (target(uri) == LinkTarget.blocked) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
