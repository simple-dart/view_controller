import 'abstract_test_view.dart';

class TestStateView extends AbstractTestView {
  late String stringParam;
  late String stateStringParam;

  TestStateView() {
    id = 'test_state_view';
    caption = 'Test State View';
  }

  @override
  Future<void> init(Map<String, String> newParams, Map<String, String>? newState) async {
    await super.init(newParams, newState);
    stringParam = params['string_param'] ?? '';
    stateStringParam = state?['state_param'] ?? '';
  }
}
