library view_spec;

import '../_specs.dart';

class Log {
  List<String> log = <String>[];

  add(String msg) => log.add(msg);
}

@NgDirective(children: NgAnnotation.TRANSCLUDE_CHILDREN, selector: 'foo')
class LoggerViewDirective {
  LoggerViewDirective(ViewPort hole, ViewFactory viewFactory,
      BoundViewFactory boundViewFactory, Logger logger) {
    assert(hole != null);
    assert(viewFactory != null);
    assert(boundViewFactory != null);

    logger.add(hole);
    logger.add(boundViewFactory);
    logger.add(viewFactory);
  }
}

@NgDirective(selector: 'dir-a')
class ADirective {
  ADirective(Log log) {
    log.add('ADirective');
  }
}

@NgDirective(selector: 'dir-b')
class BDirective {
  BDirective(Log log) {
    log.add('BDirective');
  }
}

@NgFilter(name:'filterA')
class AFilter {
  Log log;

  AFilter(this.log) {
    log.add('AFilter');
  }

  call(value) => value;
}

@NgFilter(name:'filterB')
class BFilter {
  Log log;

  BFilter(this.log) {
    log.add('BFilter');
  }

  call(value) => value;
}


main() {
  describe('View', () {
    var anchor;
    var $rootElement;
    var viewCache;

    beforeEach(() {
      $rootElement = $('<div></div>');
    });

    describe('mutation', () {
      var a, b;
      var expando = new Expando();

      beforeEach(inject((Injector injector, Profiler perf) {
        $rootElement.html('<!-- anchor -->');
        anchor = new ViewPort($rootElement.contents().eq(0));
        a = (new ViewFactory($('<span>A</span>a'), [], perf, expando))(injector);
        b = (new ViewFactory($('<span>B</span>b'), [], perf, expando))(injector);
      }));


      describe('insertAfter', () {
        it('should insert view after anchor view', () {
          a.insertAfter(anchor);

          expect($rootElement.html()).toEqual('<!-- anchor --><span>A</span>a');
          expect(anchor.next).toBe(a);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(anchor);
        });


        it('should insert multi element view after another multi element view', () {
          b.insertAfter(a.insertAfter(anchor));

          expect($rootElement.html()).toEqual('<!-- anchor --><span>A</span>a<span>B</span>b');
          expect(anchor.next).toBe(a);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(b);
          expect(a.previous).toBe(anchor);
          expect(b.next).toBe(null);
          expect(b.previous).toBe(a);
        });


        it('should insert multi element view before another multi element view', () {
          b.insertAfter(anchor);
          a.insertAfter(anchor);

          expect($rootElement.html()).toEqual('<!-- anchor --><span>A</span>a<span>B</span>b');
          expect(anchor.next).toBe(a);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(b);
          expect(a.previous).toBe(anchor);
          expect(b.next).toBe(null);
          expect(b.previous).toBe(a);
        });
      });


      describe('remove', () {
        beforeEach(() {
          b.insertAfter(a.insertAfter(anchor));

          expect($rootElement.text()).toEqual('AaBb');
        });

        it('should remove the last view', () {
          b.remove();
          expect($rootElement.html()).toEqual('<!-- anchor --><span>A</span>a');
          expect(anchor.next).toBe(a);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(anchor);
          expect(b.next).toBe(null);
          expect(b.previous).toBe(null);
        });

        it('should remove child views from parent pseudo black', () {
          a.remove();
          expect($rootElement.html()).toEqual('<!-- anchor --><span>B</span>b');
          expect(anchor.next).toBe(b);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(null);
          expect(b.next).toBe(null);
          expect(b.previous).toBe(anchor);
        });

        xit('should remove', inject((Logger logger, Injector injector, Profiler perf, ElementBinderFactory ebf) {
          a.remove();
          b.remove();

          // TODO(dart): I really want to do this:
          // class Directive {
          //   Directive(ViewPort $anchor, Logger logger) {
          //     logger.add($anchor);
          //   }
          // }

          var directiveRef = new DirectiveRef(null,
                                              LoggerViewDirective,
                                              new NgDirective(children: NgAnnotation.TRANSCLUDE_CHILDREN, selector: 'foo'),
                                              '');
          directiveRef.viewFactory = new ViewFactory($('<b>text</b>'), [], perf, new Expando());
          var binder = ebf.binder();
          binder.setTemplateInfo(0, [ directiveRef ]);
          var outerViewType = new ViewFactory(
              $('<!--start--><!--end-->'),
              [binder],
              perf,
              new Expando());

          var outterView = outerViewType(injector);
          // The LoggerViewDirective caused a ViewPort for innerViewType to
          // be created at logger[0];
          ViewPort outterAnchor = logger[0];
          BoundViewFactory outterBoundViewFactory = logger[1];

          outterView.insertAfter(anchor);
          // outterAnchor is a ViewPort, but it has "elements" set to the 0th element
          // of outerViewType.  So, calling insertAfter() will insert the new
          // view after the <!--start--> element.
          outterBoundViewFactory(null).insertAfter(outterAnchor);

          expect($rootElement.text()).toEqual('text');

          outterView.remove();

          expect($rootElement.text()).toEqual('');
        }));
      });


      describe('moveAfter', () {
        beforeEach(() {
          b.insertAfter(a.insertAfter(anchor));

          expect($rootElement.text()).toEqual('AaBb');
        });


        it('should move last to middle', () {
          b.moveAfter(anchor);
          expect($rootElement.html()).toEqual('<!-- anchor --><span>B</span>b<span>A</span>a');
          expect(anchor.next).toBe(b);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(b);
          expect(b.next).toBe(a);
          expect(b.previous).toBe(anchor);
        });


        it('should move middle to last', () {
          a.moveAfter(b);
          expect($rootElement.html()).toEqual('<!-- anchor --><span>B</span>b<span>A</span>a');
          expect(anchor.next).toBe(b);
          expect(anchor.previous).toBe(null);
          expect(a.next).toBe(null);
          expect(a.previous).toBe(b);
          expect(b.next).toBe(a);
          expect(b.previous).toBe(anchor);
        });
      });
    });

    describe('deferred', () {

      it('should load directives/filters from the child injector', () {
        Module rootModule = new Module()
          ..type(Probe)
          ..type(Log)
          ..type(AFilter)
          ..type(ADirective);

        Injector rootInjector =
            new DynamicInjector(modules: [new AngularModule(), rootModule]);
        Log log = rootInjector.get(Log);
        Scope rootScope = rootInjector.get(Scope);

        Compiler compiler = rootInjector.get(Compiler);
        DirectiveMap directives = rootInjector.get(DirectiveMap);
        compiler(es('<dir-a>{{\'a\' | filterA}}</dir-a><dir-b></dir-b>'), directives)(rootInjector);
        rootScope.apply();

        expect(log.log, equals(['ADirective', 'AFilter']));


        Module childModule = new Module()
          ..type(BFilter)
          ..type(BDirective);

        var childInjector = forceNewDirectivesAndFilters(rootInjector, [childModule]);

        DirectiveMap newDirectives = childInjector.get(DirectiveMap);
        compiler(es('<dir-a probe="dirA"></dir-a>{{\'a\' | filterA}}'
            '<dir-b probe="dirB"></dir-b>{{\'b\' | filterB}}'), newDirectives)(childInjector);
        rootScope.apply();

        expect(log.log, equals(['ADirective', 'AFilter', 'ADirective', 'BDirective', 'BFilter']));
      });

    });

    //TODO: tests for attach/detach
    //TODO: animation/transitions
    //TODO: tests for re-usability of views

  });
}
