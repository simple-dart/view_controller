import 'abstract_test_view.dart';
import 'test_parent_view.dart';

class TestChildView extends AbstractTestView {
  late String childViewParamFromParent;

  TestChildView() {
    id = 'test_child_view';
    caption = 'Test Child View';
  }

  TestParentView get parentView => parent! as TestParentView;

  @override
  Future<void> init(Map<String, String> newParams, Map<String, String>? newState) async {
    params = newParams;
    state = newState;
    childViewParamFromParent = parentView.parentViewParam;
  }
}
