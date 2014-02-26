part of angular.core.dom;

/**
 * ElementBinder is created by the Selector and is responsible for instantiating individual directives
 * and binding element properties.
 */

class ElementBinder {
  List<DirectiveRef> directives;

  ElementBinder(this.directives);
}
