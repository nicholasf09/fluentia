// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

html.EventListener? _beforeUnloadListener;

Future<void> registerBeforeUnloadHandler(Future<void> Function() onFlush) async {
  _beforeUnloadListener ??= (html.Event event) {
    onFlush();
  };
  html.window.addEventListener('beforeunload', _beforeUnloadListener);
}

Future<void> unregisterBeforeUnloadHandler() async {
  if (_beforeUnloadListener == null) return;
  html.window.removeEventListener('beforeunload', _beforeUnloadListener);
  _beforeUnloadListener = null;
}
