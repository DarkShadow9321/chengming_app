class AppConfig {
  static const appName = '承明法拍屋';
  static final website = Uri.parse('https://www.s41349.com/');
  static final properties = website.resolve('/case');
  static final news = website.resolve('/news');
  static final about = website.resolve('/about');
  static final phone = Uri.parse('tel:+886422255286');
  static const phoneLabel = '(04) 2225-5286';
  // TODO: 請客戶提供正式隱私權政策網址；不要猜測不存在的頁面。
  static final Uri? privacyPolicy = null;

  static bool isInternal(Uri uri) =>
      uri.scheme == 'https' &&
      (uri.host == 'www.s41349.com' || uri.host == 's41349.com') &&
      (!uri.hasPort || uri.port == 443) &&
      uri.userInfo.isEmpty;
}
