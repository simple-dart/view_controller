# Simple dart web views

Library for creating a single page application on Dart.

Read in other languages: [English](README.md), [Russian](README.ru.md).

## ViewController

ViewController - the controller for managing the View. Like all controllers, it is created and initialized at startup
time.
applications. Called via the global variable viewController.
Subscribes to window.onHashChange change events and changes the View.

### ViewController methods

- openView(AbstractView) - shows View.
- openPath(String) - shows View by url.
- saveState(Map<String, String> newState) - saves the state to window.location.hash and does not cause the View to be
  reinitialized.
- generateFullPath(AbstractView view) - generates the full path for the View.
- generatePathPart(String id, Map<String, String> params) - generates part of the path for View from parameters.

## AbstractView

An abstract class for changeable application screens.
Each application implements its own class, the successor of AbstractView, necessarily called View.

Each View has a unique id (for window.location navigation) and a caption (for display
titles in menus and other navigation components).

It can optionally store parameters (params) that will be passed when switching to this view.
It can also store state, which will be saved when switching to another view and restored when returning
to this view.
When the state changes, the state of the url changes, but is not processed.

A view can be a child of another view. In this case, when switching to a subordinate view, it will first
all parent View are initialized. Subviews have access to parent views.
This is needed for:

- Display structure - how the current View relates to others.
- Easier to return to the parent View.
- You can operate on the data of the parent View. For example, if the parent View is a list - then on the child View
  there may be links to the previous and next elements of the list.

The child View can be accessed via a link like: #some_parent_view?n=15/some_child_view?name=Bob

Transitions between Views must be done by reference transitions or by the openPath(String) and openView(AbstractView)
methods.
View can be accessed by a link like: #some_view?n=15

### AbstractView Properties

- id - unique id (should not contain symbols reserved for URL)
- caption - a human-readable short title of the View, by which the purpose of this View is clear.
- parent - parent View (if any). View can be subordinate(ChildView). ChildView cannot exist without
  parent View.

- params and state - are parsed from the url and passed to the init(Map<String, String> params, Map<String, String>?
  state) method.