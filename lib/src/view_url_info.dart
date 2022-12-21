class ViewUrlInfo {
  ViewUrlInfo();

  String id = '';
  Map<String, String> params = <String, String>{};
  Map<String, String> urlState = <String, String>{};

  String get urlStateString {
    final keys = urlState.keys.toList()..sort();
    final res = <String>[];
    for (final key in keys) {
      final value = urlState[key]!;
      res.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}');
    }
    return res.join('&');
  }
}
