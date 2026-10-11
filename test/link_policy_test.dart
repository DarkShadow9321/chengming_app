import 'package:flutter_test/flutter_test.dart';
import 'package:chengming_app/services/webview_service.dart';

void main() {
  test('本站 HTTPS 留在 WebView，外部安全連結交給系統', () {
    expect(
      WebviewService.target(Uri.parse('https://www.s41349.com/case')),
      LinkTarget.internal,
    );
    expect(
      WebviewService.target(Uri.parse('https://s41349.com/news')),
      LinkTarget.internal,
    );
    expect(
      WebviewService.target(Uri.parse('https://example.com/')),
      LinkTarget.external,
    );
    expect(
      WebviewService.target(Uri.parse('tel:+886422255286')),
      LinkTarget.external,
    );
    expect(
      WebviewService.target(Uri.parse('mailto:test@example.com')),
      LinkTarget.external,
    );
  });
  test('禁止 HTTP、JavaScript、file、intent 與偽造本站網址', () {
    for (final url in [
      'http://www.s41349.com/',
      'javascript:alert(1)',
      'file:///test',
      'intent://test',
      'https://user:password@www.s41349.com/',
    ]) {
      expect(WebviewService.target(Uri.parse(url)), LinkTarget.blocked);
    }
    expect(
      WebviewService.target(Uri.parse('https://www.s41349.com.evil.example/')),
      LinkTarget.external,
    );
  });
}
