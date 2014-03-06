part of angular.core.dom;

abstract class Compiler {
  ViewFactory call(List<dom.Node> elements, DirectiveMap directives);
}

