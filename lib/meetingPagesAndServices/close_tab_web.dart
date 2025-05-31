import 'dart:html' as html;

void closeCurrentTab() {
  html.window.close();
}

void changeUrl(int? i) {
  if (i == null) {
    html.window.history.pushState(null, 'Initial', '/');
  }
  final newUrl = '/courses?courseID=${i}';
  html.window.history.pushState(null, 'Course ${i}', newUrl);
}

void resetUrl() {
  html.window.history.pushState(null, 'Initial', '/');
}
