part of angular.core.dom;

/**
 * ElementBinder is created by the Selector and is responsible for instantiating individual directives
 * and binding element properties.
 */

class ElementBinder {
  List<DirectiveRef> decorators = [];

  /**
   * TODO: Make this member private.
   */
  bool skipTemplate = false;

  DirectiveRef template;

  DirectiveRef component;

  // TODO: This won't be part of the public API.
  List<DirectiveRef> get decoratorsAndComponents {
    if (component != null) {
      return new List.from(decorators)..add(component);
    }
    return decorators;
  }
}
