import 'dart:async';
import 'dart:html';

import 'package:simple_dart_view_controller/simple_dart_view_controller.dart';

import 'test_child_view.dart';
import 'test_home_view.dart';
import 'test_params_view.dart';
import 'test_parent_view.dart';
import 'test_state_view.dart';

Future<void> main() async {
  // final body = querySelector('body')!;
  print('Start test view controller');
  await testHomeView();
  await testParamsView();
  await testChildView();
  await testStateView();
  print('End test view controller');
}

Future<void> testHomeView() async {
  final homeView = TestHomeView();
  viewController.init(homeView, []);
  await Future<void>.delayed(const Duration(seconds: 1));
  if (viewController.currentView != homeView) {
    throw Exception('Current view is not home view');
  } else {
    print('testHomeView OK');
  }
}

Future<void> testParamsView() async {
  final homeView = TestHomeView();
  viewController.init(homeView, [TestParamsView()]);
  await Future<void>.delayed(const Duration(seconds: 1));
  await viewController.openPath(viewController.generatePathPart('test_params_view', {'string': 'value1', 'int': '-5'}));
  await Future<void>.delayed(const Duration(seconds: 1));
  assert(viewController.currentView is TestParamsView, 'Current view is not TestParamsView');
  assert(viewController.currentView.caption == 'test_params_view value1 (-5)', 'Current view caption is not correct');
  viewController.dispose();
  print('testParamView OK');
}

Future<void> testChildView() async {
  final homeView = TestHomeView();
  viewController.init(homeView, [TestParentView(), TestChildView()]);
  await Future<void>.delayed(const Duration(seconds: 1));
  await viewController.openPath('test_parent_view?parent_view_param=777/test_child_view');
  await Future<void>.delayed(const Duration(seconds: 1));
  assert(viewController.currentView is TestChildView, 'Current view is not TestChildView');
  final testChildView = viewController.currentView as TestChildView;
  assert(testChildView.parent is TestParentView, 'Parent view is not TestParentView');
  assert(testChildView.childViewParamFromParent == '777', 'childViewParamFromParent is not correct');
  viewController.dispose();
  print('testChildView OK');
}

Future<void> testStateView() async {
  final homeView = TestHomeView();
  viewController.init(homeView, [TestStateView()]);
  await Future<void>.delayed(const Duration(seconds: 1));
  await viewController.openPath('test_state_view?string_param=string_value');
  await Future<void>.delayed(const Duration(seconds: 1));
  assert(viewController.currentView is TestStateView, 'Current view is not TestStateView');
  final testStateView = viewController.currentView as TestStateView;
  assert(testStateView.stringParam == 'string_value', 'stringParam is not correct');
  viewController.saveState({'state_param': 'state_value'});
  assert(window.location.hash == '#test_state_view?string_param=string_value::state_param=state_value',
      'state in is not correct');
  viewController.dispose();
  print('testStateView OK');
}
