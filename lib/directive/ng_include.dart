part of angular.directive;

/**
 * Fetches, compiles and includes an external Angular template/HTML.
 *
 * A new child [Scope] is created for the included DOM subtree.
 *
 * [NgIncludeDirective] provides only one small part of the power of
 * [NgComponent].  Consider using directives and components instead as they
 * provide this feature as well as much more.
 *
 * Note: The browser's Same Origin Policy (<http://v.gd/5LE5CA>) and
 * Cross-Origin Resource Sharing (CORS) policy (<http://v.gd/nXoY8y>) restrict
 * whether the template is successfully loaded.  For example,
 * [NgIncludeDirective] won't work for cross-domain requests on all browsers and
 * for `file://` access on some browsers.
 */
@NgDirective(
    selector: '[ng-include]',
    map: const {'ng-include': '@url'})
class NgIncludeDirective {

  final dom.Element element;
  final Scope scope;
  final ViewCache blockCache;
  final Injector injector;
  final DirectiveMap directives;

  View _previousView;
  Scope _previousScope;

  NgIncludeDirective(this.element, this.scope, this.blockCache, this.injector, this.directives);

  _cleanUp() {
    if (_previousView == null) return;

    _previousView.remove();
    _previousScope.destroy();
    element.innerHtml = '';

    _previousView = null;
    _previousScope = null;
  }

  _updateContent(createView) {
    // create a new scope
    _previousScope = scope.createChild(new PrototypeMap(scope.context));
    _previousView = createView(injector.createChild([new Module()
        ..value(Scope, _previousScope)]));

    _previousView.elements.forEach((elm) => element.append(elm));
  }


  set url(value) {
    _cleanUp();
    if (value != null && value != '') {
      blockCache.fromUrl(value, directives).then(_updateContent);
    }
  }
}
