import 'dart:async';

// Abstract View
abstract class AbstractView {
  String get id;

  String get caption;

  AbstractView? get parent;

  set parent(AbstractView? _parent);

  Map<String, String> get params;

  Future<void> init(Map<String, String> params, Map<String, String>? state);
}
