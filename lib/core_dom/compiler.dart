part of angular.core.dom;

abstract class Compiler {
  WalkingViewFactory call(List<dom.Node> elements, DirectiveMap directives);
}

@NgInjectableService()
class WalkingCompiler implements Compiler {
  final Profiler _perf;
  final Expando _expando;

  WalkingCompiler(this._perf, this._expando);

  List<ElementBinderTreeRef> _compileView(NodeCursor domCursor, NodeCursor templateCursor,
                ElementBinder useExistingElementBinder,
                DirectiveMap directives) {
    if (domCursor.nodeList().length == 0) return null;

    List<ElementBinderTreeRef> elementBinders = null; // don't pre-create to create sparse tree and prevent GC pressure.

    do {
      var subtrees, binder;

      ElementBinder elementBinder = useExistingElementBinder == null
          ?  directives.selector(domCursor.nodeList()[0])
          : useExistingElementBinder;

      if (elementBinder.hasTemplate) {
        elementBinder.templateViewFactory = _compileTransclusion(
            domCursor, templateCursor,
            elementBinder.template, elementBinder.templateBinder, directives);
      }

      if (elementBinder.shouldCompileChildren) {
        if (domCursor.descend()) {
          templateCursor.descend();

          subtrees =
              _compileView(domCursor, templateCursor, null, directives);

          domCursor.ascend();
          templateCursor.ascend();
        }
      }

      if (elementBinder.hasDirectives) {
        binder = elementBinder;
      }

      if (elementBinders == null) elementBinders = [];
      elementBinders.add(new ElementBinderTreeRef(templateCursor.index, new ElementBinderTree(binder, subtrees)));
    } while (templateCursor.microNext() && domCursor.microNext());

    return elementBinders;
  }

  WalkingViewFactory _compileTransclusion(
                      NodeCursor domCursor, NodeCursor templateCursor,
                      DirectiveRef directiveRef,
                      ElementBinder transcludedElementBinder,
                      DirectiveMap directives) {
    var anchorName = directiveRef.annotation.selector + (directiveRef.value != null ? '=' + directiveRef.value : '');
    var viewFactory;
    var views;

    var transcludeCursor = templateCursor.replaceWithAnchor(anchorName);
    var domCursorIndex = domCursor.index;
    var elementBinders =
        _compileView(domCursor, transcludeCursor, transcludedElementBinder, directives);
    if (elementBinders == null) elementBinders = [];

    viewFactory = new WalkingViewFactory(transcludeCursor.elements, elementBinders, _perf, _expando);
    domCursor.index = domCursorIndex;

    if (domCursor.isInstance()) {
      domCursor.insertAnchorBefore(anchorName);
      views = [viewFactory(domCursor.nodeList())];
      domCursor.macroNext();
      templateCursor.macroNext();
      while (domCursor.isValid() && domCursor.isInstance()) {
        views.add(viewFactory(domCursor.nodeList()));
        domCursor.macroNext();
        templateCursor.remove();
      }
    } else {
      domCursor.replaceWithAnchor(anchorName);
    }

    return viewFactory;
  }

  WalkingViewFactory call(List<dom.Node> elements, DirectiveMap directives) {
    var timerId;
    assert((timerId = _perf.startTimer('ng.compile', _html(elements))) != false);
    List<dom.Node> domElements = elements;
    List<dom.Node> templateElements = cloneElements(domElements);
    var elementBinders = _compileView(
        new NodeCursor(domElements), new NodeCursor(templateElements),
        null, directives);

    var viewFactory = new WalkingViewFactory(templateElements,
        elementBinders == null ? [] : elementBinders, _perf, _expando);

    assert(_perf.stopTimer(timerId) != false);
    return viewFactory;
  }
}
