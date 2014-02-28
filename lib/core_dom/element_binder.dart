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

  // Can be either COMPILE_CHILDREN or IGNORE_CHILDREN
  String childMode = NgAnnotation.COMPILE_CHILDREN;

  // TODO: This won't be part of the public API.
  List<DirectiveRef> get decoratorsAndComponents {
    if (component != null) {
      return new List.from(decorators)..add(component);
    }
    return decorators;
  }

  addDirective(DirectiveRef ref) {
    var annotation = ref.annotation;
    var children = annotation.children;

    if (annotation.children == NgAnnotation.TRANSCLUDE_CHILDREN) {
      template = ref;
    } else if(annotation is NgComponent) {
      component = ref;
    } else {
      decorators.add(ref);
    }

    if (annotation.children == NgAnnotation.IGNORE_CHILDREN) {
      childMode = annotation.children;
    }
  }
}
