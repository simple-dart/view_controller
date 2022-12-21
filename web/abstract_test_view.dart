import 'package:simple_dart_view_controller/src/abstract_view.dart';

class AbstractTestView implements AbstractView {
  @override
  String caption = '';

  @override
  String id = '';
  @override
  AbstractView? parent;
  @override
  Map<String, String> params = {};

  Map<String, String>? state;

  @override
  Future<void> init(Map<String, String> newParams, Map<String, String>? newState) async {
    params = newParams;
    state = newState;
  }
}
