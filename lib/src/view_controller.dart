// ignore_for_file: prefer_collection_literals

import 'dart:async';
import 'dart:collection';
import 'dart:html';

import 'abstract_view.dart';
import 'view_url_info.dart';

ViewController viewController = ViewController();

class ViewController {
  late AbstractView homeView;
  late AbstractView currentView;
  late String urlStateSeparator = '::';
  late LinkedHashMap<String, AbstractView> views;
  late StreamController<AbstractView> _onViewChange;
  late StreamSubscription _onHashChangeSubs;

  Stream<AbstractView> get onViewChange => _onViewChange.stream;

  void init(AbstractView homeView, List<AbstractView> newViews, {String newUrlStateSeparator = ''}) {
    views = LinkedHashMap<String, AbstractView>();
    _onViewChange = StreamController<AbstractView>.broadcast(sync: true);
    this.homeView = homeView;
    currentView = homeView;
    if (newUrlStateSeparator.isNotEmpty) {
      urlStateSeparator = newUrlStateSeparator;
    }
    _onHashChangeSubs = window.onHashChange.listen((event) {
      if (event is HashChangeEvent) {
        var oldUrl = event.oldUrl ?? '';
        var newUrl = event.newUrl ?? '';
        if (oldUrl.contains(urlStateSeparator)) {
          oldUrl = oldUrl.substring(0, oldUrl.indexOf(urlStateSeparator));
        }
        if (newUrl.contains(urlStateSeparator)) {
          newUrl = newUrl.substring(0, newUrl.indexOf(urlStateSeparator));
        }
        if (newUrl != oldUrl) {
          _openPath(window.location.hash);
        }
      }
    });
    _addView(homeView);
    newViews.forEach(_addView);
    if (window.location.hash.isEmpty) {
      openView(homeView);
    } else {
      try {
        _openPath(window.location.hash);
      } on Exception catch (_) {
        openView(homeView);
      }
    }
  }

  Future<void> openPath(String path) async {
    window.location.hash = path;
  }

  Future<void> _openPath(String path) async {
    final view = await getViewByPath(path);
    if (view == null) {
      await _showView(homeView);
    } else {
      await _showView(view);
    }
  }

  Future<void> _showView(AbstractView view) async {
    currentView = view;
    _onViewChange.sink.add(view);
  }

  void openView(AbstractView view) {
    window.location.hash = generateFullPath(view);
  }

  Future<AbstractView?> getViewByPath(String newPath) async {
    var path = newPath;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.startsWith('#')) {
      path = path.substring(1);
    }
    if (path.isEmpty) {
      return homeView;
    }
    final viewUrls = path.split('/');
    final firstUrl = viewUrls.removeAt(0);
    final rootViewUrlInfo = _parseUrlPart(firstUrl);
    final rootView = views[rootViewUrlInfo.id];
    if (rootView == null) {
      print('warning: view "${rootViewUrlInfo.id}" is not registered');
      return null;
    }
    await rootView.init(rootViewUrlInfo.params, rootViewUrlInfo.urlState);
    var parentView = rootView;
    for (final viewUrl in viewUrls) {
      if (viewUrl.isNotEmpty) {
        final childViewUrlInfo = _parseUrlPart(viewUrl);
        final childView = views[childViewUrlInfo.id];
        if (childView == null) {
          print('warning: child view "${childViewUrlInfo.id}" is not registered');
          return null;
        }
        childView.parent = parentView;
        await childView.init(childViewUrlInfo.params, childViewUrlInfo.urlState);
        parentView = childView;
      }
    }
    return parentView;
  }

  void _addView(AbstractView view) {
    if (view.id.isEmpty) {
      throw Exception('error: register view without id ${view.runtimeType}');
    }
    views[view.id] = view;
  }

  // parse url part like "viewId?param1=value1&param2=value2::urlState"
  ViewUrlInfo _parseUrlPart(String urlPart) {
    var id = '';
    var params = <String, String>{};
    var urlState = <String, String>{};
    var urlPartWithoutState = urlPart;
    if (urlPartWithoutState.contains(urlStateSeparator)) {
      final split = urlPartWithoutState.split(urlStateSeparator);
      urlPartWithoutState = split.first;
      urlState = Uri.splitQueryString(split.last);
    }
    if (urlPartWithoutState.contains('?')) {
      final split = urlPartWithoutState.split('?');
      id = split.first;
      params = Uri.splitQueryString(split.last);
    } else {
      id = urlPartWithoutState;
    }
    return ViewUrlInfo()
      ..id = id
      ..params = params
      ..urlState = urlState;
  }

  void saveState(Map<String, String> newState) {
    final oldHash = window.location.hash;
    if (oldHash.contains(urlStateSeparator)) {
      final split = oldHash.split(urlStateSeparator);
      final urlInfo = _parseUrlPart(oldHash);
      urlInfo.urlState.addAll(newState);
      window.history.replaceState({}, '', '${split.first}$urlStateSeparator${urlInfo.urlStateString}');
    } else {
      final urlInfo = ViewUrlInfo();
      urlInfo.urlState.addAll(newState);
      window.history.replaceState({}, '', '$oldHash$urlStateSeparator${urlInfo.urlStateString}');
    }
  }

  String generateFullPath(AbstractView view) {
    final encodedLastViewPath = generatePathPart(view.id, view.params);
    var lastParentView = view.parent;
    if (lastParentView == null) {
      return '#$encodedLastViewPath';
    }
    final viewsList = <AbstractView>[];
    while (lastParentView != null) {
      viewsList.add(lastParentView);
      lastParentView = lastParentView.parent;
    }
    final buffer = StringBuffer()..write('#');
    for (final view in viewsList.reversed) {
      final encodedViewPath = generatePathPart(view.id, view.params);
      buffer.write('$encodedViewPath/');
    }
    return buffer.toString() + encodedLastViewPath;
  }

  String generatePathPart(String id, Map<String, String> params) {
    var result = id;
    if (params.isNotEmpty) {
      result += '?';
      var isFirst = true;
      params.forEach((key, value) {
        if (isFirst) {
          result += '$key=${Uri.encodeQueryComponent(value)}';
          isFirst = false;
        } else {
          result += '&$key=${Uri.encodeQueryComponent(value)}';
        }
      });
    }
    return result;
  }

  void dispose() {
    _onHashChangeSubs.cancel();
    _onViewChange.close();
  }
}
