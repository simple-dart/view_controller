import 'abstract_test_view.dart';

class TestParentView extends AbstractTestView {
  late String parentViewParam;

  TestParentView() {
    id = 'test_parent_view';
    caption = 'Test Parent View';
  }

  @override
  Future<void> init(Map<String, String> newParams, Map<String, String>? newState) async {
    await super.init(newParams, newState);
    parentViewParam = newParams['parent_view_param'] ?? '';
  }
}
