import 'abstract_test_view.dart';

class TestParamsView extends AbstractTestView {
  late int intParam;
  late String stringParam;

  TestParamsView() {
    id = 'test_params_view';
    caption = '';
  }

  @override
  Future<void> init(Map<String, String> params, Map<String, String>? state) async {
    await super.init(params, state);
    stringParam = params['string'] ?? '';
    intParam = int.parse(params['int'] ?? '0');
    caption = '$id $stringParam ($intParam)';
  }
}
