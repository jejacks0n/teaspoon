/**
 * QUnit v1.10.0 - A JavaScript Unit Testing Framework
 *
 * http://qunitjs.com
 *
 * Copyright 2012 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 */


(function( window ) {

  var QUnit,
      config,
      onErrorFnPrev,
      testId = 0,
      fileName = (sourceFromStacktrace( 0 ) || "" ).replace(/(:\d+)+\)?/, "").replace(/.+\//, ""),
      toString = Object.prototype.toString,
      hasOwn = Object.prototype.hasOwnProperty,
  // Keep a local reference to Date (GH-283)
      Date = window.Date,
      defined = {
        setTimeout: typeof window.setTimeout !== "undefined",
        sessionStorage: (function() {
          var x = "qunit-test-string";
          try {
            sessionStorage.setItem( x, x );
            sessionStorage.removeItem( x );
            return true;
          } catch( e ) {
            return false;
          }
        }())
      };

  function Test( settings ) {
    extend( this, settings );
    this.assertions = [];
    this.testNumber = ++Test.count;
  }

  Test.count = 0;

  Test.prototype = {
    init: function() {
      var a, b, li,
          tests = id( "qunit-tests" );

      if ( tests ) {
        b = document.createElement( "strong" );
        b.innerHTML = this.name;

        // `a` initialized at top of scope
        a = document.createElement( "a" );
        a.innerHTML = "Rerun";
        a.href = QUnit.url({ testNumber: this.testNumber });

        li = document.createElement( "li" );
        li.appendChild( b );
        li.appendChild( a );
        li.className = "running";
        li.id = this.id = "qunit-test-output" + testId++;

        tests.appendChild( li );
      }
    },
    setup: function() {
      if ( this.module !== config.previousModule ) {
        if ( config.previousModule ) {
          runLoggingCallbacks( "moduleDone", QUnit, {
            name: config.previousModule,
            failed: config.moduleStats.bad,
            passed: config.moduleStats.all - config.moduleStats.bad,
            total: config.moduleStats.all
          });
        }
        config.previousModule = this.module;
        config.moduleStats = { all: 0, bad: 0 };
        runLoggingCallbacks( "moduleStart", QUnit, {
          name: this.module
        });
      } else if ( config.autorun ) {
        runLoggingCallbacks( "moduleStart", QUnit, {
          name: this.module
        });
      }

      config.current = this;

      this.testEnvironment = extend({
        setup: function() {},
        teardown: function() {}
      }, this.moduleTestEnvironment );

      runLoggingCallbacks( "testStart", QUnit, {
        name: this.testName,
        module: this.module
      });

      // allow utility functions to access the current test environment
      // TODO why??
      QUnit.current_testEnvironment = this.testEnvironment;

      if ( !config.pollution ) {
        saveGlobal();
      }
      if ( config.notrycatch ) {
        this.testEnvironment.setup.call( this.testEnvironment );
        return;
      }
      try {
        this.testEnvironment.setup.call( this.testEnvironment );
      } catch( e ) {
        QUnit.pushFailure( "Setup failed on " + this.testName + ": " + e.message, extractStacktrace( e, 1 ) );
      }
    },
    run: function() {
      config.current = this;

      var running = id( "qunit-testresult" );

      if ( running ) {
        running.innerHTML = "Running: <br/>" + this.name;
      }

      if ( this.async ) {
        QUnit.stop();
      }

      if ( config.notrycatch ) {
        this.callback.call( this.testEnvironment, QUnit.assert );
        return;
      }

      try {
        this.callback.call( this.testEnvironment, QUnit.assert );
      } catch( e ) {
        QUnit.pushFailure( "Died on test #" + (this.assertions.length + 1) + " " + this.stack + ": " + e.message, extractStacktrace( e, 0 ) );
        // else next test will carry the responsibility
        saveGlobal();

        // Restart the tests if they're blocking
        if ( config.blocking ) {
          QUnit.start();
        }
      }
    },
    teardown: function() {
      config.current = this;
      if ( config.notrycatch ) {
        this.testEnvironment.teardown.call( this.testEnvironment );
        return;
      } else {
        try {
          this.testEnvironment.teardown.call( this.testEnvironment );
        } catch( e ) {
          QUnit.pushFailure( "Teardown failed on " + this.testName + ": " + e.message, extractStacktrace( e, 1 ) );
        }
      }
      checkPollution();
    },
    finish: function() {
      config.current = this;
      if ( config.requireExpects && this.expected == null ) {
        QUnit.pushFailure( "Expected number of assertions to be defined, but expect() was not called.", this.stack );
      } else if ( this.expected != null && this.expected != this.assertions.length ) {
        QUnit.pushFailure( "Expected " + this.expected + " assertions, but " + this.assertions.length + " were run", this.stack );
      } else if ( this.expected == null && !this.assertions.length ) {
        QUnit.pushFailure( "Expected at least one assertion, but none were run - call expect(0) to accept zero assertions.", this.stack );
      }

      var assertion, a, b, i, li, ol,
          test = this,
          good = 0,
          bad = 0,
          tests = id( "qunit-tests" );

      config.stats.all += this.assertions.length;
      config.moduleStats.all += this.assertions.length;

      if ( tests ) {
        ol = document.createElement( "ol" );

        for ( i = 0; i < this.assertions.length; i++ ) {
          assertion = this.assertions[i];

          li = document.createElement( "li" );
          li.className = assertion.result ? "pass" : "fail";
          li.innerHTML = assertion.message || ( assertion.result ? "okay" : "failed" );
          ol.appendChild( li );

          if ( assertion.result ) {
            good++;
          } else {
            bad++;
            config.stats.bad++;
            config.moduleStats.bad++;
          }
        }

        // store result when possible
        if ( QUnit.config.reorder && defined.sessionStorage ) {
          if ( bad ) {
            sessionStorage.setItem( "qunit-test-" + this.module + "-" + this.testName, bad );
          } else {
            sessionStorage.removeItem( "qunit-test-" + this.module + "-" + this.testName );
          }
        }

        if ( bad === 0 ) {
          ol.style.display = "none";
        }

        // `b` initialized at top of scope
        b = document.createElement( "strong" );
        b.innerHTML = this.name + " <b class='counts'>(<b class='failed'>" + bad + "</b>, <b class='passed'>" + good + "</b>, " + this.assertions.length + ")</b>";

        addEvent(b, "click", function() {
          var next = b.nextSibling.nextSibling,
              display = next.style.display;
          next.style.display = display === "none" ? "block" : "none";
        });

        addEvent(b, "dblclick", function( e ) {
          var target = e && e.target ? e.target : window.event.srcElement;
          if ( target.nodeName.toLowerCase() == "span" || target.nodeName.toLowerCase() == "b" ) {
            target = target.parentNode;
          }
          if ( window.location && target.nodeName.toLowerCase() === "strong" ) {
            window.location = QUnit.url({ testNumber: test.testNumber });
          }
        });

        // `li` initialized at top of scope
        li = id( this.id );
        li.className = bad ? "fail" : "pass";
        li.removeChild( li.firstChild );
        a = li.firstChild;
        li.appendChild( b );
        li.appendChild ( a );
        li.appendChild( ol );

      } else {
        for ( i = 0; i < this.assertions.length; i++ ) {
          if ( !this.assertions[i].result ) {
            bad++;
            config.stats.bad++;
            config.moduleStats.bad++;
          }
        }
      }

      runLoggingCallbacks( "testDone", QUnit, {
        name: this.testName,
        module: this.module,
        failed: bad,
        passed: this.assertions.length - bad,
        total: this.assertions.length
      });

      QUnit.reset();

      config.current = undefined;
    },

    queue: function() {
      var bad,
          test = this;

      synchronize(function() {
        test.init();
      });
      function run() {
        // each of these can by async
        synchronize(function() {
          test.setup();
        });
        synchronize(function() {
          test.run();
        });
        synchronize(function() {
          test.teardown();
        });
        synchronize(function() {
          test.finish();
        });
      }

      // `bad` initialized at top of scope
      // defer when previous test run passed, if storage is available
      bad = QUnit.config.reorder && defined.sessionStorage &&
          +sessionStorage.getItem( "qunit-test-" + this.module + "-" + this.testName );

      if ( bad ) {
        run();
      } else {
        synchronize( run, true );
      }
    }
  };

// Root QUnit object.
// `QUnit` initialized at top of scope
  QUnit = {

    // call on start of module test to prepend name to all tests
    module: function( name, testEnvironment ) {
      config.currentModule = name;
      config.currentModuleTestEnvironment = testEnvironment;
      config.modules[name] = true;
    },

    asyncTest: function( testName, expected, callback ) {
      if ( arguments.length === 2 ) {
        callback = expected;
        expected = null;
      }

      QUnit.test( testName, expected, callback, true );
    },

    test: function( testName, expected, callback, async ) {
      var test,
          name = "<span class='test-name'>" + escapeInnerText( testName ) + "</span>";

      if ( arguments.length === 2 ) {
        callback = expected;
        expected = null;
      }

      if ( config.currentModule ) {
        name = "<span class='module-name'>" + config.currentModule + "</span>: " + name;
      }

      test = new Test({
        name: name,
        testName: testName,
        expected: expected,
        async: async,
        callback: callback,
        module: config.currentModule,
        moduleTestEnvironment: config.currentModuleTestEnvironment,
        stack: sourceFromStacktrace( 2 )
      });

      if ( !validTest( test ) ) {
        return;
      }

      test.queue();
    },

    // Specify the number of expected assertions to gurantee that failed test (no assertions are run at all) don't slip through.
    expect: function( asserts ) {
      if (arguments.length === 1) {
        config.current.expected = asserts;
      } else {
        return config.current.expected;
      }
    },

    start: function( count ) {
      config.semaphore -= count || 1;
      // don't start until equal number of stop-calls
      if ( config.semaphore > 0 ) {
        return;
      }
      // ignore if start is called more often then stop
      if ( config.semaphore < 0 ) {
        config.semaphore = 0;
      }
      // A slight delay, to avoid any current callbacks
      if ( defined.setTimeout ) {
        window.setTimeout(function() {
          if ( config.semaphore > 0 ) {
            return;
          }
          if ( config.timeout ) {
            clearTimeout( config.timeout );
          }

          config.blocking = false;
          process( true );
        }, 13);
      } else {
        config.blocking = false;
        process( true );
      }
    },

    stop: function( count ) {
      config.semaphore += count || 1;
      config.blocking = true;

      if ( config.testTimeout && defined.setTimeout ) {
        clearTimeout( config.timeout );
        config.timeout = window.setTimeout(function() {
          QUnit.ok( false, "Test timed out" );
          config.semaphore = 1;
          QUnit.start();
        }, config.testTimeout );
      }
    }
  };

// Asssert helpers
// All of these must call either QUnit.push() or manually do:
// - runLoggingCallbacks( "log", .. );
// - config.current.assertions.push({ .. });
  QUnit.assert = {
    /**
     * Asserts rough true-ish result.
     * @name ok
     * @function
     * @example ok( "asdfasdf".length > 5, "There must be at least 5 chars" );
     */
    ok: function( result, msg ) {
      if ( !config.current ) {
        throw new Error( "ok() assertion outside test context, was " + sourceFromStacktrace(2) );
      }
      result = !!result;

      var source,
          details = {
            module: config.current.module,
            name: config.current.testName,
            result: result,
            message: msg
          };

      msg = escapeInnerText( msg || (result ? "okay" : "failed" ) );
      msg = "<span class='test-message'>" + msg + "</span>";

      if ( !result ) {
        source = sourceFromStacktrace( 2 );
        if ( source ) {
          details.source = source;
          msg += "<table><tr class='test-source'><th>Source: </th><td><pre>" + escapeInnerText( source ) + "</pre></td></tr></table>";
        }
      }
      runLoggingCallbacks( "log", QUnit, details );
      config.current.assertions.push({
        result: result,
        message: msg
      });
    },

    /**
     * Assert that the first two arguments are equal, with an optional message.
     * Prints out both actual and expected values.
     * @name equal
     * @function
     * @example equal( format( "Received {0} bytes.", 2), "Received 2 bytes.", "format() replaces {0} with next argument" );
     */
    equal: function( actual, expected, message ) {
      QUnit.push( expected == actual, actual, expected, message );
    },

    /**
     * @name notEqual
     * @function
     */
    notEqual: function( actual, expected, message ) {
      QUnit.push( expected != actual, actual, expected, message );
    },

    /**
     * @name deepEqual
     * @function
     */
    deepEqual: function( actual, expected, message ) {
      QUnit.push( QUnit.equiv(actual, expected), actual, expected, message );
    },

    /**
     * @name notDeepEqual
     * @function
     */
    notDeepEqual: function( actual, expected, message ) {
      QUnit.push( !QUnit.equiv(actual, expected), actual, expected, message );
    },

    /**
     * @name strictEqual
     * @function
     */
    strictEqual: function( actual, expected, message ) {
      QUnit.push( expected === actual, actual, expected, message );
    },

    /**
     * @name notStrictEqual
     * @function
     */
    notStrictEqual: function( actual, expected, message ) {
      QUnit.push( expected !== actual, actual, expected, message );
    },

    throws: function( block, expected, message ) {
      var actual,
          ok = false;

      // 'expected' is optional
      if ( typeof expected === "string" ) {
        message = expected;
        expected = null;
      }

      config.current.ignoreGlobalErrors = true;
      try {
        block.call( config.current.testEnvironment );
      } catch (e) {
        actual = e;
      }
      config.current.ignoreGlobalErrors = false;

      if ( actual ) {
        // we don't want to validate thrown error
        if ( !expected ) {
          ok = true;
          // expected is a regexp
        } else if ( QUnit.objectType( expected ) === "regexp" ) {
          ok = expected.test( actual );
          // expected is a constructor
        } else if ( actual instanceof expected ) {
          ok = true;
          // expected is a validation function which returns true is validation passed
        } else if ( expected.call( {}, actual ) === true ) {
          ok = true;
        }

        QUnit.push( ok, actual, null, message );
      } else {
        QUnit.pushFailure( message, null, 'No exception was thrown.' );
      }
    }
  };

  /**
   * @deprecate since 1.8.0
   * Kept assertion helpers in root for backwards compatibility
   */
  extend( QUnit, QUnit.assert );

  /**
   * @deprecated since 1.9.0
   * Kept global "raises()" for backwards compatibility
   */
  QUnit.raises = QUnit.assert.throws;

  /**
   * @deprecated since 1.0.0, replaced with error pushes since 1.3.0
   * Kept to avoid TypeErrors for undefined methods.
   */
  QUnit.equals = function() {
    QUnit.push( false, false, false, "QUnit.equals has been deprecated since 2009 (e88049a0), use QUnit.equal instead" );
  };
  QUnit.same = function() {
    QUnit.push( false, false, false, "QUnit.same has been deprecated since 2009 (e88049a0), use QUnit.deepEqual instead" );
  };

// We want access to the constructor's prototype
  (function() {
    function F() {}
    F.prototype = QUnit;
    QUnit = new F();
    // Make F QUnit's constructor so that we can add to the prototype later
    QUnit.constructor = F;
  }());

  /**
   * Config object: Maintain internal state
   * Later exposed as QUnit.config
   * `config` initialized at top of scope
   */
  config = {
    // The queue of tests to run
    queue: [],

    // block until document ready
    blocking: true,

    // when enabled, show only failing tests
    // gets persisted through sessionStorage and can be changed in UI via checkbox
    hidepassed: false,

    // by default, run previously failed tests first
    // very useful in combination with "Hide passed tests" checked
    reorder: true,

    // by default, modify document.title when suite is done
    altertitle: true,

    // when enabled, all tests must call expect()
    requireExpects: false,

    // add checkboxes that are persisted in the query-string
    // when enabled, the id is set to `true` as a `QUnit.config` property
    urlConfig: [
      {
        id: "noglobals",
        label: "Check for Globals",
        tooltip: "Enabling this will test if any test introduces new properties on the `window` object. Stored as query-strings."
      },
      {
        id: "notrycatch",
        label: "No try-catch",
        tooltip: "Enabling this will run tests outside of a try-catch block. Makes debugging exceptions in IE reasonable. Stored as query-strings."
      }
    ],

    // Set of all modules.
    modules: {},

    // logging callback queues
    begin: [],
    done: [],
    log: [],
    testStart: [],
    testDone: [],
    moduleStart: [],
    moduleDone: []
  };

// Initialize more QUnit.config and QUnit.urlParams
  (function() {
    var i,
        location = window.location || { search: "", protocol: "file:" },
        params = location.search.slice( 1 ).split( "&" ),
        length = params.length,
        urlParams = {},
        current;

    if ( params[ 0 ] ) {
      for ( i = 0; i < length; i++ ) {
        current = params[ i ].split( "=" );
        current[ 0 ] = decodeURIComponent( current[ 0 ] );
        // allow just a key to turn on a flag, e.g., test.html?noglobals
        current[ 1 ] = current[ 1 ] ? decodeURIComponent( current[ 1 ] ) : true;
        urlParams[ current[ 0 ] ] = current[ 1 ];
      }
    }

    QUnit.urlParams = urlParams;

    // String search anywhere in moduleName+testName
    config.filter = urlParams.filter;

    // Exact match of the module name
    config.module = urlParams.module;

    config.testNumber = parseInt( urlParams.testNumber, 10 ) || null;

    // Figure out if we're running the tests from a server or not
    QUnit.isLocal = location.protocol === "file:";
  }());

// Export global variables, unless an 'exports' object exists,
// in that case we assume we're in CommonJS (dealt with on the bottom of the script)
  if ( typeof exports === "undefined" ) {
    extend( window, QUnit );

    // Expose QUnit object
    window.QUnit = QUnit;
  }

// Extend QUnit object,
// these after set here because they should not be exposed as global functions
  extend( QUnit, {
    config: config,

    // Initialize the configuration options
    init: function() {
      extend( config, {
        stats: { all: 0, bad: 0 },
        moduleStats: { all: 0, bad: 0 },
        started: +new Date(),
        updateRate: 1000,
        blocking: false,
        autostart: true,
        autorun: false,
        filter: "",
        queue: [],
        semaphore: 0
      });

      var tests, banner, result,
          qunit = id( "qunit" );

      if ( qunit ) {
        qunit.innerHTML =
            "<h1 id='qunit-header'>" + escapeInnerText( document.title ) + "</h1>" +
                "<h2 id='qunit-banner'></h2>" +
                "<div id='qunit-testrunner-toolbar'></div>" +
                "<h2 id='qunit-userAgent'></h2>" +
                "<ol id='qunit-tests'></ol>";
      }

      tests = id( "qunit-tests" );
      banner = id( "qunit-banner" );
      result = id( "qunit-testresult" );

      if ( tests ) {
        tests.innerHTML = "";
      }

      if ( banner ) {
        banner.className = "";
      }

      if ( result ) {
        result.parentNode.removeChild( result );
      }

      if ( tests ) {
        result = document.createElement( "p" );
        result.id = "qunit-testresult";
        result.className = "result";
        tests.parentNode.insertBefore( result, tests );
        result.innerHTML = "Running...<br/>&nbsp;";
      }
    },

    // Resets the test setup. Useful for tests that modify the DOM.
    reset: function() {
      var fixture = id( "qunit-fixture" );
      if ( fixture ) {
        fixture.innerHTML = config.fixture;
      }
    },

    // Trigger an event on an element.
    // @example triggerEvent( document.body, "click" );
    triggerEvent: function( elem, type, event ) {
      if ( document.createEvent ) {
        event = document.createEvent( "MouseEvents" );
        event.initMouseEvent(type, true, true, elem.ownerDocument.defaultView,
            0, 0, 0, 0, 0, false, false, false, false, 0, null);

        elem.dispatchEvent( event );
      } else if ( elem.fireEvent ) {
        elem.fireEvent( "on" + type );
      }
    },

    // Safe object type checking
    is: function( type, obj ) {
      return QUnit.objectType( obj ) == type;
    },

    objectType: function( obj ) {
      if ( typeof obj === "undefined" ) {
        return "undefined";
        // consider: typeof null === object
      }
      if ( obj === null ) {
        return "null";
      }

      var type = toString.call( obj ).match(/^\[object\s(.*)\]$/)[1] || "";

      switch ( type ) {
        case "Number":
          if ( isNaN(obj) ) {
            return "nan";
          }
          return "number";
        case "String":
        case "Boolean":
        case "Array":
        case "Date":
        case "RegExp":
        case "Function":
          return type.toLowerCase();
      }
      if ( typeof obj === "object" ) {
        return "object";
      }
      return undefined;
    },

    push: function( result, actual, expected, message ) {
      if ( !config.current ) {
        throw new Error( "assertion outside test context, was " + sourceFromStacktrace() );
      }

      var output, source,
          details = {
            module: config.current.module,
            name: config.current.testName,
            result: result,
            message: message,
            actual: actual,
            expected: expected
          };

      message = escapeInnerText( message ) || ( result ? "okay" : "failed" );
      message = "<span class='test-message'>" + message + "</span>";
      output = message;

      if ( !result ) {
        expected = escapeInnerText( QUnit.jsDump.parse(expected) );
        actual = escapeInnerText( QUnit.jsDump.parse(actual) );
        output += "<table><tr class='test-expected'><th>Expected: </th><td><pre>" + expected + "</pre></td></tr>";

        if ( actual != expected ) {
          output += "<tr class='test-actual'><th>Result: </th><td><pre>" + actual + "</pre></td></tr>";
          output += "<tr class='test-diff'><th>Diff: </th><td><pre>" + QUnit.diff( expected, actual ) + "</pre></td></tr>";
        }

        source = sourceFromStacktrace();

        if ( source ) {
          details.source = source;
          output += "<tr class='test-source'><th>Source: </th><td><pre>" + escapeInnerText( source ) + "</pre></td></tr>";
        }

        output += "</table>";
      }

      runLoggingCallbacks( "log", QUnit, details );

      config.current.assertions.push({
        result: !!result,
        message: output
      });
    },

    pushFailure: function( message, source, actual ) {
      if ( !config.current ) {
        throw new Error( "pushFailure() assertion outside test context, was " + sourceFromStacktrace(2) );
      }

      var output,
          details = {
            module: config.current.module,
            name: config.current.testName,
            result: false,
            message: message
          };

      message = escapeInnerText( message ) || "error";
      message = "<span class='test-message'>" + message + "</span>";
      output = message;

      output += "<table>";

      if ( actual ) {
        output += "<tr class='test-actual'><th>Result: </th><td><pre>" + escapeInnerText( actual ) + "</pre></td></tr>";
      }

      if ( source ) {
        details.source = source;
        output += "<tr class='test-source'><th>Source: </th><td><pre>" + escapeInnerText( source ) + "</pre></td></tr>";
      }

      output += "</table>";

      runLoggingCallbacks( "log", QUnit, details );

      config.current.assertions.push({
        result: false,
        message: output
      });
    },

    url: function( params ) {
      params = extend( extend( {}, QUnit.urlParams ), params );
      var key,
          querystring = "?";

      for ( key in params ) {
        if ( !hasOwn.call( params, key ) ) {
          continue;
        }
        querystring += encodeURIComponent( key ) + "=" +
            encodeURIComponent( params[ key ] ) + "&";
      }
      return window.location.pathname + querystring.slice( 0, -1 );
    },

    extend: extend,
    id: id,
    addEvent: addEvent
    // load, equiv, jsDump, diff: Attached later
  });

  /**
   * @deprecated: Created for backwards compatibility with test runner that set the hook function
   * into QUnit.{hook}, instead of invoking it and passing the hook function.
   * QUnit.constructor is set to the empty F() above so that we can add to it's prototype here.
   * Doing this allows us to tell if the following methods have been overwritten on the actual
   * QUnit object.
   */
  extend( QUnit.constructor.prototype, {

    // Logging callbacks; all receive a single argument with the listed properties
    // run test/logs.html for any related changes
    begin: registerLoggingCallback( "begin" ),

    // done: { failed, passed, total, runtime }
    done: registerLoggingCallback( "done" ),

    // log: { result, actual, expected, message }
    log: registerLoggingCallback( "log" ),

    // testStart: { name }
    testStart: registerLoggingCallback( "testStart" ),

    // testDone: { name, failed, passed, total }
    testDone: registerLoggingCallback( "testDone" ),

    // moduleStart: { name }
    moduleStart: registerLoggingCallback( "moduleStart" ),

    // moduleDone: { name, failed, passed, total }
    moduleDone: registerLoggingCallback( "moduleDone" )
  });

  if ( typeof document === "undefined" || document.readyState === "complete" ) {
    config.autorun = true;
  }

  QUnit.load = function() {
    runLoggingCallbacks( "begin", QUnit, {} );

    // Initialize the config, saving the execution queue
    var banner, filter, i, label, len, main, ol, toolbar, userAgent, val, urlConfigCheckboxes, moduleFilter,
        numModules = 0,
        moduleFilterHtml = "",
        urlConfigHtml = "",
        oldconfig = extend( {}, config );

    QUnit.init();
    extend(config, oldconfig);

    config.blocking = false;

    len = config.urlConfig.length;

    for ( i = 0; i < len; i++ ) {
      val = config.urlConfig[i];
      if ( typeof val === "string" ) {
        val = {
          id: val,
          label: val,
          tooltip: "[no tooltip available]"
        };
      }
      config[ val.id ] = QUnit.urlParams[ val.id ];
      urlConfigHtml += "<input id='qunit-urlconfig-" + val.id + "' name='" + val.id + "' type='checkbox'" + ( config[ val.id ] ? " checked='checked'" : "" ) + " title='" + val.tooltip + "'><label for='qunit-urlconfig-" + val.id + "' title='" + val.tooltip + "'>" + val.label + "</label>";
    }

    moduleFilterHtml += "<label for='qunit-modulefilter'>Module: </label><select id='qunit-modulefilter' name='modulefilter'><option value='' " + ( config.module === undefined  ? "selected" : "" ) + ">< All Modules ></option>";
    for ( i in config.modules ) {
      if ( config.modules.hasOwnProperty( i ) ) {
        numModules += 1;
        moduleFilterHtml += "<option value='" + encodeURIComponent(i) + "' " + ( config.module === i ? "selected" : "" ) + ">" + i + "</option>";
      }
    }
    moduleFilterHtml += "</select>";

    // `userAgent` initialized at top of scope
    userAgent = id( "qunit-userAgent" );
    if ( userAgent ) {
      userAgent.innerHTML = navigator.userAgent;
    }

    // `banner` initialized at top of scope
    banner = id( "qunit-header" );
    if ( banner ) {
      banner.innerHTML = "<a href='" + QUnit.url({ filter: undefined, module: undefined, testNumber: undefined }) + "'>" + banner.innerHTML + "</a> ";
    }

    // `toolbar` initialized at top of scope
    toolbar = id( "qunit-testrunner-toolbar" );
    if ( toolbar ) {
      // `filter` initialized at top of scope
      filter = document.createElement( "input" );
      filter.type = "checkbox";
      filter.id = "qunit-filter-pass";

      addEvent( filter, "click", function() {
        var tmp,
            ol = document.getElementById( "qunit-tests" );

        if ( filter.checked ) {
          ol.className = ol.className + " hidepass";
        } else {
          tmp = " " + ol.className.replace( /[\n\t\r]/g, " " ) + " ";
          ol.className = tmp.replace( / hidepass /, " " );
        }
        if ( defined.sessionStorage ) {
          if (filter.checked) {
            sessionStorage.setItem( "qunit-filter-passed-tests", "true" );
          } else {
            sessionStorage.removeItem( "qunit-filter-passed-tests" );
          }
        }
      });

      if ( config.hidepassed || defined.sessionStorage && sessionStorage.getItem( "qunit-filter-passed-tests" ) ) {
        filter.checked = true;
        // `ol` initialized at top of scope
        ol = document.getElementById( "qunit-tests" );
        ol.className = ol.className + " hidepass";
      }
      toolbar.appendChild( filter );

      // `label` initialized at top of scope
      label = document.createElement( "label" );
      label.setAttribute( "for", "qunit-filter-pass" );
      label.setAttribute( "title", "Only show tests and assertons that fail. Stored in sessionStorage." );
      label.innerHTML = "Hide passed tests";
      toolbar.appendChild( label );

      urlConfigCheckboxes = document.createElement( 'span' );
      urlConfigCheckboxes.innerHTML = urlConfigHtml;
      addEvent( urlConfigCheckboxes, "change", function( event ) {
        var params = {};
        params[ event.target.name ] = event.target.checked ? true : undefined;
        window.location = QUnit.url( params );
      });
      toolbar.appendChild( urlConfigCheckboxes );

      if (numModules > 1) {
        moduleFilter = document.createElement( 'span' );
        moduleFilter.setAttribute( 'id', 'qunit-modulefilter-container' );
        moduleFilter.innerHTML = moduleFilterHtml;
        addEvent( moduleFilter, "change", function() {
          var selectBox = moduleFilter.getElementsByTagName("select")[0],
              selectedModule = decodeURIComponent(selectBox.options[selectBox.selectedIndex].value);

          window.location = QUnit.url( { module: ( selectedModule === "" ) ? undefined : selectedModule } );
        });
        toolbar.appendChild(moduleFilter);
      }
    }

    // `main` initialized at top of scope
    main = id( "qunit-fixture" );
    if ( main ) {
      config.fixture = main.innerHTML;
    }

    if ( config.autostart ) {
      QUnit.start();
    }
  };

  addEvent( window, "load", QUnit.load );

// `onErrorFnPrev` initialized at top of scope
// Preserve other handlers
  onErrorFnPrev = window.onerror;

// Cover uncaught exceptions
// Returning true will surpress the default browser handler,
// returning false will let it run.
  window.onerror = function ( error, filePath, linerNr ) {
    var ret = false;
    if ( onErrorFnPrev ) {
      ret = onErrorFnPrev( error, filePath, linerNr );
    }

    // Treat return value as window.onerror itself does,
    // Only do our handling if not surpressed.
    if ( ret !== true ) {
      if ( QUnit.config.current ) {
        if ( QUnit.config.current.ignoreGlobalErrors ) {
          return true;
        }
        QUnit.pushFailure( error, filePath + ":" + linerNr );
      } else {
        QUnit.test( "global failure", extend( function() {
          QUnit.pushFailure( error, filePath + ":" + linerNr );
        }, { validTest: validTest } ) );
      }
      return false;
    }

    return ret;
  };

  function done() {
    config.autorun = true;

    // Log the last module results
    if ( config.currentModule ) {
      runLoggingCallbacks( "moduleDone", QUnit, {
        name: config.currentModule,
        failed: config.moduleStats.bad,
        passed: config.moduleStats.all - config.moduleStats.bad,
        total: config.moduleStats.all
      });
    }

    var i, key,
        banner = id( "qunit-banner" ),
        tests = id( "qunit-tests" ),
        runtime = +new Date() - config.started,
        passed = config.stats.all - config.stats.bad,
        html = [
          "Tests completed in ",
          runtime,
          " milliseconds.<br/>",
          "<span class='passed'>",
          passed,
          "</span> tests of <span class='total'>",
          config.stats.all,
          "</span> passed, <span class='failed'>",
          config.stats.bad,
          "</span> failed."
        ].join( "" );

    if ( banner ) {
      banner.className = ( config.stats.bad ? "qunit-fail" : "qunit-pass" );
    }

    if ( tests ) {
      id( "qunit-testresult" ).innerHTML = html;
    }

    if ( config.altertitle && typeof document !== "undefined" && document.title ) {
      // show ✖ for good, ✔ for bad suite result in title
      // use escape sequences in case file gets loaded with non-utf-8-charset
      document.title = [
        ( config.stats.bad ? "\u2716" : "\u2714" ),
        document.title.replace( /^[\u2714\u2716] /i, "" )
      ].join( " " );
    }

    // clear own sessionStorage items if all tests passed
    if ( config.reorder && defined.sessionStorage && config.stats.bad === 0 ) {
      // `key` & `i` initialized at top of scope
      for ( i = 0; i < sessionStorage.length; i++ ) {
        key = sessionStorage.key( i++ );
        if ( key.indexOf( "qunit-test-" ) === 0 ) {
          sessionStorage.removeItem( key );
        }
      }
    }

    // scroll back to top to show results
    if ( window.scrollTo ) {
      window.scrollTo(0, 0);
    }

    runLoggingCallbacks( "done", QUnit, {
      failed: config.stats.bad,
      passed: passed,
      total: config.stats.all,
      runtime: runtime
    });
  }

  /** @return Boolean: true if this test should be ran */
  function validTest( test ) {
    var include,
        filter = config.filter && config.filter.toLowerCase(),
        module = config.module && config.module.toLowerCase(),
        fullName = (test.module + ": " + test.testName).toLowerCase();

    // Internally-generated tests are always valid
    if ( test.callback && test.callback.validTest === validTest ) {
      delete test.callback.validTest;
      return true;
    }

    if ( config.testNumber ) {
      return test.testNumber === config.testNumber;
    }

    if ( module && ( !test.module || test.module.toLowerCase() !== module ) ) {
      return false;
    }

    if ( !filter ) {
      return true;
    }

    include = filter.charAt( 0 ) !== "!";
    if ( !include ) {
      filter = filter.slice( 1 );
    }

    // If the filter matches, we need to honour include
    if ( fullName.indexOf( filter ) !== -1 ) {
      return include;
    }

    // Otherwise, do the opposite
    return !include;
  }

// so far supports only Firefox, Chrome and Opera (buggy), Safari (for real exceptions)
// Later Safari and IE10 are supposed to support error.stack as well
// See also https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Error/Stack
  function extractStacktrace( e, offset ) {
    offset = offset === undefined ? 3 : offset;

    var stack, include, i, regex;

    if ( e.stacktrace ) {
      // Opera
      return e.stacktrace.split( "\n" )[ offset + 3 ];
    } else if ( e.stack ) {
      // Firefox, Chrome
      stack = e.stack.split( "\n" );
      if (/^error$/i.test( stack[0] ) ) {
        stack.shift();
      }
      if ( fileName ) {
        include = [];
        for ( i = offset; i < stack.length; i++ ) {
          if ( stack[ i ].indexOf( fileName ) != -1 ) {
            break;
          }
          include.push( stack[ i ] );
        }
        if ( include.length ) {
          return include.join( "\n" );
        }
      }
      return stack[ offset ];
    } else if ( e.sourceURL ) {
      // Safari, PhantomJS
      // hopefully one day Safari provides actual stacktraces
      // exclude useless self-reference for generated Error objects
      if ( /qunit.js$/.test( e.sourceURL ) ) {
        return;
      }
      // for actual exceptions, this is useful
      return e.sourceURL + ":" + e.line;
    }
  }
  function sourceFromStacktrace( offset ) {
    try {
      throw new Error();
    } catch ( e ) {
      return extractStacktrace( e, offset );
    }
  }

  function escapeInnerText( s ) {
    if ( !s ) {
      return "";
    }
    s = s + "";
    return s.replace( /[\&<>]/g, function( s ) {
      switch( s ) {
        case "&": return "&amp;";
        case "<": return "&lt;";
        case ">": return "&gt;";
        default: return s;
      }
    });
  }

  function synchronize( callback, last ) {
    config.queue.push( callback );

    if ( config.autorun && !config.blocking ) {
      process( last );
    }
  }

  function process( last ) {
    function next() {
      process( last );
    }
    var start = new Date().getTime();
    config.depth = config.depth ? config.depth + 1 : 1;

    while ( config.queue.length && !config.blocking ) {
      if ( !defined.setTimeout || config.updateRate <= 0 || ( ( new Date().getTime() - start ) < config.updateRate ) ) {
        config.queue.shift()();
      } else {
        window.setTimeout( next, 13 );
        break;
      }
    }
    config.depth--;
    if ( last && !config.blocking && !config.queue.length && config.depth === 0 ) {
      done();
    }
  }

  function saveGlobal() {
    config.pollution = [];

    if ( config.noglobals ) {
      for ( var key in window ) {
        // in Opera sometimes DOM element ids show up here, ignore them
        if ( !hasOwn.call( window, key ) || /^qunit-test-output/.test( key ) ) {
          continue;
        }
        config.pollution.push( key );
      }
    }
  }

  function checkPollution( name ) {
    var newGlobals,
        deletedGlobals,
        old = config.pollution;

    saveGlobal();

    newGlobals = diff( config.pollution, old );
    if ( newGlobals.length > 0 ) {
      QUnit.pushFailure( "Introduced global variable(s): " + newGlobals.join(", ") );
    }

    deletedGlobals = diff( old, config.pollution );
    if ( deletedGlobals.length > 0 ) {
      QUnit.pushFailure( "Deleted global variable(s): " + deletedGlobals.join(", ") );
    }
  }

// returns a new Array with the elements that are in a but not in b
  function diff( a, b ) {
    var i, j,
        result = a.slice();

    for ( i = 0; i < result.length; i++ ) {
      for ( j = 0; j < b.length; j++ ) {
        if ( result[i] === b[j] ) {
          result.splice( i, 1 );
          i--;
          break;
        }
      }
    }
    return result;
  }

  function extend( a, b ) {
    for ( var prop in b ) {
      if ( b[ prop ] === undefined ) {
        delete a[ prop ];

        // Avoid "Member not found" error in IE8 caused by setting window.constructor
      } else if ( prop !== "constructor" || a !== window ) {
        a[ prop ] = b[ prop ];
      }
    }

    return a;
  }

  function addEvent( elem, type, fn ) {
    if ( elem.addEventListener ) {
      elem.addEventListener( type, fn, false );
    } else if ( elem.attachEvent ) {
      elem.attachEvent( "on" + type, fn );
    } else {
      fn();
    }
  }

  function id( name ) {
    return !!( typeof document !== "undefined" && document && document.getElementById ) &&
        document.getElementById( name );
  }

  function registerLoggingCallback( key ) {
    return function( callback ) {
      config[key].push( callback );
    };
  }

// Supports deprecated method of completely overwriting logging callbacks
  function runLoggingCallbacks( key, scope, args ) {
    //debugger;
    var i, callbacks;
    if ( QUnit.hasOwnProperty( key ) ) {
      QUnit[ key ].call(scope, args );
    } else {
      callbacks = config[ key ];
      for ( i = 0; i < callbacks.length; i++ ) {
        callbacks[ i ].call( scope, args );
      }
    }
  }

// Test for equality any JavaScript type.
// Author: Philippe Rathé <prathe@gmail.com>
  QUnit.equiv = (function() {

    // Call the o related callback with the given arguments.
    function bindCallbacks( o, callbacks, args ) {
      var prop = QUnit.objectType( o );
      if ( prop ) {
        if ( QUnit.objectType( callbacks[ prop ] ) === "function" ) {
          return callbacks[ prop ].apply( callbacks, args );
        } else {
          return callbacks[ prop ]; // or undefined
        }
      }
    }

    // the real equiv function
    var innerEquiv,
    // stack to decide between skip/abort functions
        callers = [],
    // stack to avoiding loops from circular referencing
        parents = [],

        getProto = Object.getPrototypeOf || function ( obj ) {
          return obj.__proto__;
        },
        callbacks = (function () {

          // for string, boolean, number and null
          function useStrictEquality( b, a ) {
            if ( b instanceof a.constructor || a instanceof b.constructor ) {
              // to catch short annotaion VS 'new' annotation of a
              // declaration
              // e.g. var i = 1;
              // var j = new Number(1);
              return a == b;
            } else {
              return a === b;
            }
          }

          return {
            "string": useStrictEquality,
            "boolean": useStrictEquality,
            "number": useStrictEquality,
            "null": useStrictEquality,
            "undefined": useStrictEquality,

            "nan": function( b ) {
              return isNaN( b );
            },

            "date": function( b, a ) {
              return QUnit.objectType( b ) === "date" && a.valueOf() === b.valueOf();
            },

            "regexp": function( b, a ) {
              return QUnit.objectType( b ) === "regexp" &&
                // the regex itself
                  a.source === b.source &&
                // and its modifers
                  a.global === b.global &&
                // (gmi) ...
                  a.ignoreCase === b.ignoreCase &&
                  a.multiline === b.multiline &&
                  a.sticky === b.sticky;
            },

            // - skip when the property is a method of an instance (OOP)
            // - abort otherwise,
            // initial === would have catch identical references anyway
            "function": function() {
              var caller = callers[callers.length - 1];
              return caller !== Object && typeof caller !== "undefined";
            },

            "array": function( b, a ) {
              var i, j, len, loop;

              // b could be an object literal here
              if ( QUnit.objectType( b ) !== "array" ) {
                return false;
              }

              len = a.length;
              if ( len !== b.length ) {
                // safe and faster
                return false;
              }

              // track reference to avoid circular references
              parents.push( a );
              for ( i = 0; i < len; i++ ) {
                loop = false;
                for ( j = 0; j < parents.length; j++ ) {
                  if ( parents[j] === a[i] ) {
                    loop = true;// dont rewalk array
                  }
                }
                if ( !loop && !innerEquiv(a[i], b[i]) ) {
                  parents.pop();
                  return false;
                }
              }
              parents.pop();
              return true;
            },

            "object": function( b, a ) {
              var i, j, loop,
              // Default to true
                  eq = true,
                  aProperties = [],
                  bProperties = [];

              // comparing constructors is more strict than using
              // instanceof
              if ( a.constructor !== b.constructor ) {
                // Allow objects with no prototype to be equivalent to
                // objects with Object as their constructor.
                if ( !(( getProto(a) === null && getProto(b) === Object.prototype ) ||
                    ( getProto(b) === null && getProto(a) === Object.prototype ) ) ) {
                  return false;
                }
              }

              // stack constructor before traversing properties
              callers.push( a.constructor );
              // track reference to avoid circular references
              parents.push( a );

              for ( i in a ) { // be strict: don't ensures hasOwnProperty
                // and go deep
                loop = false;
                for ( j = 0; j < parents.length; j++ ) {
                  if ( parents[j] === a[i] ) {
                    // don't go down the same path twice
                    loop = true;
                  }
                }
                aProperties.push(i); // collect a's properties

                if (!loop && !innerEquiv( a[i], b[i] ) ) {
                  eq = false;
                  break;
                }
              }

              callers.pop(); // unstack, we are done
              parents.pop();

              for ( i in b ) {
                bProperties.push( i ); // collect b's properties
              }

              // Ensures identical properties name
              return eq && innerEquiv( aProperties.sort(), bProperties.sort() );
            }
          };
        }());

    innerEquiv = function() { // can take multiple arguments
      var args = [].slice.apply( arguments );
      if ( args.length < 2 ) {
        return true; // end transition
      }

      return (function( a, b ) {
        if ( a === b ) {
          return true; // catch the most you can
        } else if ( a === null || b === null || typeof a === "undefined" ||
            typeof b === "undefined" ||
            QUnit.objectType(a) !== QUnit.objectType(b) ) {
          return false; // don't lose time with error prone cases
        } else {
          return bindCallbacks(a, callbacks, [ b, a ]);
        }

        // apply transition with (1..n) arguments
      }( args[0], args[1] ) && arguments.callee.apply( this, args.splice(1, args.length - 1 )) );
    };

    return innerEquiv;
  }());

  /**
   * jsDump Copyright (c) 2008 Ariel Flesler - aflesler(at)gmail(dot)com |
   * http://flesler.blogspot.com Licensed under BSD
   * (http://www.opensource.org/licenses/bsd-license.php) Date: 5/15/2008
   *
   * @projectDescription Advanced and extensible data dumping for Javascript.
   * @version 1.0.0
   * @author Ariel Flesler
   * @link {http://flesler.blogspot.com/2008/05/jsdump-pretty-dump-of-any-javascript.html}
   */
  QUnit.jsDump = (function() {
    function quote( str ) {
      return '"' + str.toString().replace( /"/g, '\\"' ) + '"';
    }
    function literal( o ) {
      return o + "";
    }
    function join( pre, arr, post ) {
      var s = jsDump.separator(),
          base = jsDump.indent(),
          inner = jsDump.indent(1);
      if ( arr.join ) {
        arr = arr.join( "," + s + inner );
      }
      if ( !arr ) {
        return pre + post;
      }
      return [ pre, inner + arr, base + post ].join(s);
    }
    function array( arr, stack ) {
      var i = arr.length, ret = new Array(i);
      this.up();
      while ( i-- ) {
        ret[i] = this.parse( arr[i] , undefined , stack);
      }
      this.down();
      return join( "[", ret, "]" );
    }

    var reName = /^function (\w+)/,
        jsDump = {
          parse: function( obj, type, stack ) { //type is used mostly internally, you can fix a (custom)type in advance
            stack = stack || [ ];
            var inStack, res,
                parser = this.parsers[ type || this.typeOf(obj) ];

            type = typeof parser;
            inStack = inArray( obj, stack );

            if ( inStack != -1 ) {
              return "recursion(" + (inStack - stack.length) + ")";
            }
            //else
            if ( type == "function" )  {
              stack.push( obj );
              res = parser.call( this, obj, stack );
              stack.pop();
              return res;
            }
            // else
            return ( type == "string" ) ? parser : this.parsers.error;
          },
          typeOf: function( obj ) {
            var type;
            if ( obj === null ) {
              type = "null";
            } else if ( typeof obj === "undefined" ) {
              type = "undefined";
            } else if ( QUnit.is( "regexp", obj) ) {
              type = "regexp";
            } else if ( QUnit.is( "date", obj) ) {
              type = "date";
            } else if ( QUnit.is( "function", obj) ) {
              type = "function";
            } else if ( typeof obj.setInterval !== undefined && typeof obj.document !== "undefined" && typeof obj.nodeType === "undefined" ) {
              type = "window";
            } else if ( obj.nodeType === 9 ) {
              type = "document";
            } else if ( obj.nodeType ) {
              type = "node";
            } else if (
            // native arrays
                toString.call( obj ) === "[object Array]" ||
                  // NodeList objects
                    ( typeof obj.length === "number" && typeof obj.item !== "undefined" && ( obj.length ? obj.item(0) === obj[0] : ( obj.item( 0 ) === null && typeof obj[0] === "undefined" ) ) )
                ) {
              type = "array";
            } else {
              type = typeof obj;
            }
            return type;
          },
          separator: function() {
            return this.multiline ?	this.HTML ? "<br />" : "\n" : this.HTML ? "&nbsp;" : " ";
          },
          indent: function( extra ) {// extra can be a number, shortcut for increasing-calling-decreasing
            if ( !this.multiline ) {
              return "";
            }
            var chr = this.indentChar;
            if ( this.HTML ) {
              chr = chr.replace( /\t/g, "   " ).replace( / /g, "&nbsp;" );
            }
            return new Array( this._depth_ + (extra||0) ).join(chr);
          },
          up: function( a ) {
            this._depth_ += a || 1;
          },
          down: function( a ) {
            this._depth_ -= a || 1;
          },
          setParser: function( name, parser ) {
            this.parsers[name] = parser;
          },
          // The next 3 are exposed so you can use them
          quote: quote,
          literal: literal,
          join: join,
          //
          _depth_: 1,
          // This is the list of parsers, to modify them, use jsDump.setParser
          parsers: {
            window: "[Window]",
            document: "[Document]",
            error: "[ERROR]", //when no parser is found, shouldn"t happen
            unknown: "[Unknown]",
            "null": "null",
            "undefined": "undefined",
            "function": function( fn ) {
              var ret = "function",
                  name = "name" in fn ? fn.name : (reName.exec(fn) || [])[1];//functions never have name in IE

              if ( name ) {
                ret += " " + name;
              }
              ret += "( ";

              ret = [ ret, QUnit.jsDump.parse( fn, "functionArgs" ), "){" ].join( "" );
              return join( ret, QUnit.jsDump.parse(fn,"functionCode" ), "}" );
            },
            array: array,
            nodelist: array,
            "arguments": array,
            object: function( map, stack ) {
              var ret = [ ], keys, key, val, i;
              QUnit.jsDump.up();
              if ( Object.keys ) {
                keys = Object.keys( map );
              } else {
                keys = [];
                for ( key in map ) {
                  keys.push( key );
                }
              }
              keys.sort();
              for ( i = 0; i < keys.length; i++ ) {
                key = keys[ i ];
                val = map[ key ];
                ret.push( QUnit.jsDump.parse( key, "key" ) + ": " + QUnit.jsDump.parse( val, undefined, stack ) );
              }
              QUnit.jsDump.down();
              return join( "{", ret, "}" );
            },
            node: function( node ) {
              var a, val,
                  open = QUnit.jsDump.HTML ? "&lt;" : "<",
                  close = QUnit.jsDump.HTML ? "&gt;" : ">",
                  tag = node.nodeName.toLowerCase(),
                  ret = open + tag;

              for ( a in QUnit.jsDump.DOMAttrs ) {
                val = node[ QUnit.jsDump.DOMAttrs[a] ];
                if ( val ) {
                  ret += " " + a + "=" + QUnit.jsDump.parse( val, "attribute" );
                }
              }
              return ret + close + open + "/" + tag + close;
            },
            functionArgs: function( fn ) {//function calls it internally, it's the arguments part of the function
              var args,
                  l = fn.length;

              if ( !l ) {
                return "";
              }

              args = new Array(l);
              while ( l-- ) {
                args[l] = String.fromCharCode(97+l);//97 is 'a'
              }
              return " " + args.join( ", " ) + " ";
            },
            key: quote, //object calls it internally, the key part of an item in a map
            functionCode: "[code]", //function calls it internally, it's the content of the function
            attribute: quote, //node calls it internally, it's an html attribute value
            string: quote,
            date: quote,
            regexp: literal, //regex
            number: literal,
            "boolean": literal
          },
          DOMAttrs: {
            //attributes to dump from nodes, name=>realName
            id: "id",
            name: "name",
            "class": "className"
          },
          HTML: false,//if true, entities are escaped ( <, >, \t, space and \n )
          indentChar: "  ",//indentation unit
          multiline: true //if true, items in a collection, are separated by a \n, else just a space.
        };

    return jsDump;
  }());

// from Sizzle.js
  function getText( elems ) {
    var i, elem,
        ret = "";

    for ( i = 0; elems[i]; i++ ) {
      elem = elems[i];

      // Get the text from text nodes and CDATA nodes
      if ( elem.nodeType === 3 || elem.nodeType === 4 ) {
        ret += elem.nodeValue;

        // Traverse everything else, except comment nodes
      } else if ( elem.nodeType !== 8 ) {
        ret += getText( elem.childNodes );
      }
    }

    return ret;
  }

// from jquery.js
  function inArray( elem, array ) {
    if ( array.indexOf ) {
      return array.indexOf( elem );
    }

    for ( var i = 0, length = array.length; i < length; i++ ) {
      if ( array[ i ] === elem ) {
        return i;
      }
    }

    return -1;
  }

  /*
   * Javascript Diff Algorithm
   *  By John Resig (http://ejohn.org/)
   *  Modified by Chu Alan "sprite"
   *
   * Released under the MIT license.
   *
   * More Info:
   *  http://ejohn.org/projects/javascript-diff-algorithm/
   *
   * Usage: QUnit.diff(expected, actual)
   *
   * QUnit.diff( "the quick brown fox jumped over", "the quick fox jumps over" ) == "the  quick <del>brown </del> fox <del>jumped </del><ins>jumps </ins> over"
   */
  QUnit.diff = (function() {
    function diff( o, n ) {
      var i,
          ns = {},
          os = {};

      for ( i = 0; i < n.length; i++ ) {
        if ( ns[ n[i] ] == null ) {
          ns[ n[i] ] = {
            rows: [],
            o: null
          };
        }
        ns[ n[i] ].rows.push( i );
      }

      for ( i = 0; i < o.length; i++ ) {
        if ( os[ o[i] ] == null ) {
          os[ o[i] ] = {
            rows: [],
            n: null
          };
        }
        os[ o[i] ].rows.push( i );
      }

      for ( i in ns ) {
        if ( !hasOwn.call( ns, i ) ) {
          continue;
        }
        if ( ns[i].rows.length == 1 && typeof os[i] != "undefined" && os[i].rows.length == 1 ) {
          n[ ns[i].rows[0] ] = {
            text: n[ ns[i].rows[0] ],
            row: os[i].rows[0]
          };
          o[ os[i].rows[0] ] = {
            text: o[ os[i].rows[0] ],
            row: ns[i].rows[0]
          };
        }
      }

      for ( i = 0; i < n.length - 1; i++ ) {
        if ( n[i].text != null && n[ i + 1 ].text == null && n[i].row + 1 < o.length && o[ n[i].row + 1 ].text == null &&
            n[ i + 1 ] == o[ n[i].row + 1 ] ) {

          n[ i + 1 ] = {
            text: n[ i + 1 ],
            row: n[i].row + 1
          };
          o[ n[i].row + 1 ] = {
            text: o[ n[i].row + 1 ],
            row: i + 1
          };
        }
      }

      for ( i = n.length - 1; i > 0; i-- ) {
        if ( n[i].text != null && n[ i - 1 ].text == null && n[i].row > 0 && o[ n[i].row - 1 ].text == null &&
            n[ i - 1 ] == o[ n[i].row - 1 ]) {

          n[ i - 1 ] = {
            text: n[ i - 1 ],
            row: n[i].row - 1
          };
          o[ n[i].row - 1 ] = {
            text: o[ n[i].row - 1 ],
            row: i - 1
          };
        }
      }

      return {
        o: o,
        n: n
      };
    }

    return function( o, n ) {
      o = o.replace( /\s+$/, "" );
      n = n.replace( /\s+$/, "" );

      var i, pre,
          str = "",
          out = diff( o === "" ? [] : o.split(/\s+/), n === "" ? [] : n.split(/\s+/) ),
          oSpace = o.match(/\s+/g),
          nSpace = n.match(/\s+/g);

      if ( oSpace == null ) {
        oSpace = [ " " ];
      }
      else {
        oSpace.push( " " );
      }

      if ( nSpace == null ) {
        nSpace = [ " " ];
      }
      else {
        nSpace.push( " " );
      }

      if ( out.n.length === 0 ) {
        for ( i = 0; i < out.o.length; i++ ) {
          str += "<del>" + out.o[i] + oSpace[i] + "</del>";
        }
      }
      else {
        if ( out.n[0].text == null ) {
          for ( n = 0; n < out.o.length && out.o[n].text == null; n++ ) {
            str += "<del>" + out.o[n] + oSpace[n] + "</del>";
          }
        }

        for ( i = 0; i < out.n.length; i++ ) {
          if (out.n[i].text == null) {
            str += "<ins>" + out.n[i] + nSpace[i] + "</ins>";
          }
          else {
            // `pre` initialized at top of scope
            pre = "";

            for ( n = out.n[i].row + 1; n < out.o.length && out.o[n].text == null; n++ ) {
              pre += "<del>" + out.o[n] + oSpace[n] + "</del>";
            }
            str += " " + out.n[i].text + nSpace[i] + pre;
          }
        }
      }

      return str;
    };
  }());

// for CommonJS enviroments, export everything
  if ( typeof exports !== "undefined" ) {
    extend(exports, QUnit);
  }

// get at whatever the global object is, like window in browsers
}( (function() {return this;}.call()) ));
(function() {

  this.Teabag = (function() {

    function Teabag() {}

    Teabag.defer = false;

    Teabag.slow = 75;

    Teabag.root = null;

    Teabag.started = false;

    Teabag.finished = false;

    Teabag.Reporters = {};

    Teabag.Date = Date;

    Teabag.location = window.location;

    Teabag.messages = [];

    Teabag.execute = function() {
      if (this.defer) {
        this.defer = false;
        return;
      }
      this.started = true;
      return new Teabag.Runner();
    };

    Teabag.resolveDependenciesFromParams = function(all) {
      var dep, deps, file, parts, path, paths, _i, _j, _len, _len1;
      if (all == null) {
        all = [];
      }
      deps = [];
      if ((paths = this.location.search.match(/[\?&]file(\[\])?=[^&\?]*/gi)) === null) {
        return all;
      }
      for (_i = 0, _len = paths.length; _i < _len; _i++) {
        path = paths[_i];
        parts = decodeURIComponent(path.replace(/\+/g, " ")).match(/\/(.+)\.(js|js.coffee|coffee)$/i);
        if (parts === null) {
          continue;
        }
        file = parts[1].substr(parts[1].lastIndexOf("/") + 1);
        for (_j = 0, _len1 = all.length; _j < _len1; _j++) {
          dep = all[_j];
          if (dep.indexOf(file) >= 0) {
            deps.push(dep);
          }
        }
      }
      return deps;
    };

    Teabag.log = function() {
      this.messages.push(arguments[0]);
      try {
        return console.log.apply(console, arguments);
      } catch (e) {
        throw new Error("Unable to use console.log for logging");
      }
    };

    Teabag.getMessages = function() {
      var messages;
      messages = this.messages;
      this.messages = [];
      return messages;
    };

    return Teabag;

  })();

}).call(this);
(function() {

  Teabag.Runner = (function() {

    Runner.run = false;

    function Runner() {
      if (this.constructor.run) {
        return;
      }
      this.constructor.run = true;
      this.fixturePath = "" + Teabag.root + "/fixtures";
      this.params = Teabag.params = this.getParams();
      this.setup();
    }

    Runner.prototype.getParams = function() {
      var name, param, params, value, _i, _len, _ref, _ref1;
      params = {};
      _ref = Teabag.location.search.substring(1).split("&");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        param = _ref[_i];
        _ref1 = param.split("="), name = _ref1[0], value = _ref1[1];
        params[decodeURIComponent(name)] = decodeURIComponent(value);
      }
      return params;
    };

    Runner.prototype.getReporter = function() {
      if (this.params["reporter"]) {
        return Teabag.Reporters[this.params["reporter"]];
      } else {
        if (window.navigator.userAgent.match(/PhantomJS/)) {
          return Teabag.Reporters.Console;
        } else {
          return Teabag.Reporters.HTML;
        }
      }
    };

    Runner.prototype.setup = function() {};

    return Runner;

  })();

}).call(this);
(function() {
  var __slice = [].slice;

  Teabag.fixture = (function() {
    var addContent, cleanup, create, load, loadComplete, preload, putContent, set, xhr, xhrRequest,
      _this = this;

    fixture.cache = {};

    fixture.el = null;

    fixture.json = [];

    fixture.preload = function() {
      var url, urls, _i, _len, _results;
      urls = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = urls.length; _i < _len; _i++) {
        url = urls[_i];
        _results.push(preload(url));
      }
      return _results;
    };

    fixture.load = function() {
      var append, index, url, urls, _i, _j, _len, _results;
      urls = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), append = arguments[_i++];
      if (append == null) {
        append = false;
      }
      if (typeof append !== "boolean") {
        urls.push(append);
        append = false;
      }
      _results = [];
      for (index = _j = 0, _len = urls.length; _j < _len; index = ++_j) {
        url = urls[index];
        _results.push(load(url, append || index > 0));
      }
      return _results;
    };

    fixture.set = function() {
      var append, html, htmls, index, _i, _j, _len, _results;
      htmls = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), append = arguments[_i++];
      if (append == null) {
        append = false;
      }
      if (typeof append !== "boolean") {
        htmls.push(append);
        append = false;
      }
      _results = [];
      for (index = _j = 0, _len = htmls.length; _j < _len; index = ++_j) {
        html = htmls[index];
        _results.push(set(html, append || index > 0));
      }
      return _results;
    };

    fixture.cleanup = function() {
      return cleanup();
    };

    function fixture() {
      Teabag.fixture.load.apply(window, arguments);
    }

    xhr = null;

    preload = function(url) {
      return load(url, false, true);
    };

    load = function(url, append, preload) {
      var cached, value;
      if (preload == null) {
        preload = false;
      }
      if (cached = Teabag.fixture.cache[url]) {
        return loadComplete(url, cached.type, cached.content, append, preload);
      }
      value = null;
      xhrRequest(url, function() {
        if (xhr.readyState !== 4) {
          return;
        }
        if (xhr.status !== 200) {
          throw "Unable to load fixture \"" + url + "\".";
        }
        return value = loadComplete(url, xhr.getResponseHeader("content-type"), xhr.responseText, append, preload);
      });
      return value;
    };

    loadComplete = function(url, type, content, append, preload) {
      Teabag.fixture.cache[url] = {
        type: type,
        content: content
      };
      if (type.match(/application\/json;/)) {
        return fixture.json[fixture.json.push(JSON.parse(content)) - 1];
      }
      if (preload) {
        return content;
      }
      if (append) {
        addContent(content);
      } else {
        putContent(content);
      }
      return Teabag.fixture.el;
    };

    set = function(content, append) {
      if (append) {
        return addContent(content);
      } else {
        return putContent(content);
      }
    };

    putContent = function(content) {
      cleanup();
      create();
      return Teabag.fixture.el.innerHTML = content;
    };

    addContent = function(content) {
      if (!Teabag.fixture.el) {
        create();
      }
      return Teabag.fixture.el.innerHTML += content;
    };

    create = function() {
      var _ref;
      Teabag.fixture.el = document.createElement("div");
      Teabag.fixture.el.id = "teabag-fixtures";
      return (_ref = document.body) != null ? _ref.appendChild(Teabag.fixture.el) : void 0;
    };

    cleanup = function() {
      var _base, _ref, _ref1;
      (_base = Teabag.fixture).el || (_base.el = document.getElementById("teabag-fixtures"));
      if ((_ref = Teabag.fixture.el) != null) {
        if ((_ref1 = _ref.parentNode) != null) {
          _ref1.removeChild(Teabag.fixture.el);
        }
      }
      return Teabag.fixture.el = null;
    };

    xhrRequest = function(url, callback) {
      if (window.XMLHttpRequest) {
        xhr = new XMLHttpRequest();
      } else if (window.ActiveXObject) {
        try {
          xhr = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e) {
          try {
            xhr = new ActiveXObject("Microsoft.XMLHTTP");
          } catch (e) {

          }
        }
      }
      if (!xhr) {
        throw "Unable to make Ajax Request";
      }
      xhr.onreadystatechange = callback;
      xhr.open("GET", "" + Teabag.root + "/fixtures/" + url, false);
      return xhr.send();
    };

    return fixture;

  }).call(this);

}).call(this);
(function() {

  Teabag.Reporters.BaseView = (function() {

    function BaseView() {
      this.elements = {};
      this.build();
    }

    BaseView.prototype.build = function(className) {
      return this.el = this.createEl("li", className);
    };

    BaseView.prototype.appendTo = function(el) {
      return el.appendChild(this.el);
    };

    BaseView.prototype.append = function(el) {
      return this.el.appendChild(el);
    };

    BaseView.prototype.createEl = function(type, className) {
      var el;
      if (className == null) {
        className = "";
      }
      el = document.createElement(type);
      el.className = className;
      return el;
    };

    BaseView.prototype.findEl = function(id) {
      var _base;
      this.elements || (this.elements = {});
      return (_base = this.elements)[id] || (_base[id] = document.getElementById("teabag-" + id));
    };

    BaseView.prototype.setText = function(id, value) {
      var el;
      el = this.findEl(id);
      return el.innerHTML = value;
    };

    BaseView.prototype.setHtml = function(id, value, add) {
      var el;
      if (add == null) {
        add = false;
      }
      el = this.findEl(id);
      if (add) {
        return el.innerHTML += value;
      } else {
        return el.innerHTML = value;
      }
    };

    BaseView.prototype.setClass = function(id, value) {
      var el;
      el = this.findEl(id);
      return el.className = value;
    };

    BaseView.prototype.htmlSafe = function(str) {
      var el;
      el = document.createElement("div");
      el.appendChild(document.createTextNode(str));
      return el.innerHTML;
    };

    return BaseView;

  })();

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Teabag.Reporters.HTML = (function(_super) {

    __extends(HTML, _super);

    function HTML() {
      this.toggleConfig = __bind(this.toggleConfig, this);

      this.reportRunnerResults = __bind(this.reportRunnerResults, this);
      this.start = new Teabag.Date().getTime();
      this.config = {
        "use-catch": true,
        "build-full-report": false,
        "display-progress": true
      };
      this.total = {
        exist: 0,
        run: 0,
        passes: 0,
        failures: 0,
        skipped: 0
      };
      this.views = {
        specs: {},
        suites: {}
      };
      this.filters = [];
      this.setFilters();
      this.readConfig();
      HTML.__super__.constructor.apply(this, arguments);
    }

    HTML.prototype.build = function() {
      var _ref;
      this.buildLayout();
      this.setText("env-info", this.envInfo());
      this.setText("version", Teabag.version);
      this.findEl("toggles").onclick = this.toggleConfig;
      this.findEl("suites").innerHTML = this.buildSuiteSelect();
      if ((_ref = this.findEl("suite-select")) != null) {
        _ref.onchange = this.changeSuite;
      }
      this.findEl("root-link").href = Teabag.root;
      this.el = this.findEl("report-all");
      this.showConfiguration();
      this.buildProgress();
      return this.buildFilters();
    };

    HTML.prototype.buildLayout = function() {
      var el;
      el = this.createEl("div");
      el.id = "teabag-interface";
      el.innerHTML = Teabag.Reporters.HTML.template;
      return document.body.appendChild(el);
    };

    HTML.prototype.buildSuiteSelect = function() {
      var options, suite, _i, _len, _ref;
      if (Teabag.suites.all.length === 1) {
        return "";
      }
      options = [];
      _ref = Teabag.suites.all;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        suite = _ref[_i];
        options.push("<option" + (Teabag.suites.active === suite ? " selected='selected'" : "") + " value=\"" + suite + "\">" + suite + "</option>");
      }
      return "<select id=\"teabag-suite-select\">" + (options.join("")) + "</select>";
    };

    HTML.prototype.buildProgress = function() {
      this.progress = Teabag.Reporters.HTML.ProgressView.create(this.config["display-progress"]);
      return this.progress.appendTo(this.findEl("progress"));
    };

    HTML.prototype.buildFilters = function() {
      if (this.filters.length) {
        this.setClass("filter", "teabag-filtered");
      }
      return this.setHtml("filter-list", "<li>" + (this.filters.join("</li><li>")), true);
    };

    HTML.prototype.reportRunnerStarting = function(runner) {
      this.total.exist = runner.total || (typeof runner.specs === "function" ? runner.specs().length : void 0) || 0;
      if (this.total.exist) {
        return this.setText("stats-duration", "...");
      }
    };

    HTML.prototype.reportSpecStarting = function(spec) {
      spec = new Teabag.Spec(spec);
      if (this.config["build-full-report"]) {
        this.reportView = new Teabag.Reporters.HTML.SpecView(spec, this);
      }
      return this.specStart = new Teabag.Date().getTime();
    };

    HTML.prototype.reportSpecResults = function(spec) {
      this.total.run += 1;
      this.updateProgress();
      return this.updateStatus(spec);
    };

    HTML.prototype.reportRunnerResults = function() {
      if (!this.total.run) {
        return;
      }
      this.setText("stats-duration", this.elapsedTime());
      if (!this.total.failures) {
        this.setStatus("passed");
      }
      this.setText("stats-passes", this.total.passes);
      this.setText("stats-failures", this.total.failures);
      if (this.total.run < this.total.exist) {
        this.total.skipped = this.total.exist - this.total.run;
        this.total.run = this.total.exist;
      }
      this.setText("stats-skipped", this.total.skipped);
      return this.updateProgress();
    };

    HTML.prototype.elapsedTime = function() {
      return "" + (((new Teabag.Date().getTime() - this.start) / 1000).toFixed(3)) + "s";
    };

    HTML.prototype.updateStat = function(name, value) {
      if (!this.config["display-progress"]) {
        return;
      }
      return this.setText("stats-" + name, value);
    };

    HTML.prototype.updateStatus = function(spec) {
      var elapsed, result, _ref, _ref1;
      spec = new Teabag.Spec(spec);
      result = spec.result();
      if (result.skipped || result.status === "pending") {
        this.updateStat("skipped", this.total.skipped += 1);
        return;
      }
      elapsed = new Teabag.Date().getTime() - this.specStart;
      if (result.status === "passed") {
        this.updateStat("passes", this.total.passes += 1);
        return (_ref = this.reportView) != null ? _ref.updateState("passed", elapsed) : void 0;
      } else {
        this.updateStat("failures", this.total.failures += 1);
        if ((_ref1 = this.reportView) != null) {
          _ref1.updateState("failed", elapsed);
        }
        if (!this.config["build-full-report"]) {
          new Teabag.Reporters.HTML.FailureView(spec).appendTo(this.findEl("report-failures"));
        }
        return this.setStatus("failed");
      }
    };

    HTML.prototype.updateProgress = function() {
      return this.progress.update(this.total.exist, this.total.run);
    };

    HTML.prototype.showConfiguration = function() {
      var key, value, _ref, _results;
      _ref = this.config;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(this.setClass(key, value ? "active" : ""));
      }
      return _results;
    };

    HTML.prototype.setStatus = function(status) {
      return document.body.className = "teabag-" + status;
    };

    HTML.prototype.setFilters = function() {
      var link;
      link = [Teabag.root, Teabag.suites.active].join('/');
      if (Teabag.params["file"]) {
        this.filters.push("<a href='" + link + "'>remove</a> by file: " + Teabag.params["file"]);
      }
      if (Teabag.params["grep"]) {
        return this.filters.push("<a href='" + link + "'>remove</a> by match: " + Teabag.params["grep"]);
      }
    };

    HTML.prototype.readConfig = function() {
      var config;
      if (config = this.cookie("teabag")) {
        return this.config = config;
      }
    };

    HTML.prototype.toggleConfig = function(e) {
      var button, name;
      button = e.target;
      if (button.tagName.toLowerCase() !== "button") {
        return;
      }
      name = button.getAttribute("id").replace(/^teabag-/, "");
      this.config[name] = !this.config[name];
      this.cookie("teabag", this.config);
      return this.refresh();
    };

    HTML.prototype.changeSuite = function() {
      return window.location.href = [Teabag.root, this.options[this.options.selectedIndex].value].join('/');
    };

    HTML.prototype.refresh = function() {
      return window.location.href = window.location.href;
    };

    HTML.prototype.cookie = function(name, value) {
      var date, match;
      if (value == null) {
        value = void 0;
      }
      if (value === void 0) {
        name = name.replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1");
        match = document.cookie.match(new RegExp("(?:^|;)\\s?" + name + "=(.*?)(?:;|$)", "i"));
        return match && JSON.parse(unescape(match[1]).split(" ")[0]);
      } else {
        date = new Teabag.Date();
        date.setDate(date.getDate() + 365);
        return document.cookie = "" + name + "=" + (escape(JSON.stringify(value))) + "; expires=" + (date.toUTCString()) + "; path=/;";
      }
    };

    return HTML;

  })(Teabag.Reporters.BaseView);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Teabag.Reporters.HTML.ProgressView = (function(_super) {

    __extends(ProgressView, _super);

    function ProgressView() {
      return ProgressView.__super__.constructor.apply(this, arguments);
    }

    ProgressView.create = function(displayProgress) {
      if (displayProgress == null) {
        displayProgress = true;
      }
      if (!displayProgress) {
        return new Teabag.Reporters.HTML.ProgressView();
      }
      if (Teabag.Reporters.HTML.RadialProgressView.supported) {
        return new Teabag.Reporters.HTML.RadialProgressView();
      } else {
        return new Teabag.Reporters.HTML.SimpleProgressView();
      }
    };

    ProgressView.prototype.build = function() {
      return this.el = this.createEl("div", "teabag-indicator modeset-logo");
    };

    ProgressView.prototype.update = function() {};

    return ProgressView;

  })(Teabag.Reporters.BaseView);

  Teabag.Reporters.HTML.SimpleProgressView = (function(_super) {

    __extends(SimpleProgressView, _super);

    function SimpleProgressView() {
      return SimpleProgressView.__super__.constructor.apply(this, arguments);
    }

    SimpleProgressView.prototype.build = function() {
      this.el = this.createEl("div", "simple-progress");
      return this.el.innerHTML = "<em id=\"teabag-progress-percent\">0%</em>\n<span id=\"teabag-progress-span\" class=\"teabag-indicator\"></span>";
    };

    SimpleProgressView.prototype.update = function(total, run) {
      var percent;
      percent = total ? Math.ceil((run * 100) / total) : 0;
      return this.setHtml("progress-percent", "" + percent + "%");
    };

    return SimpleProgressView;

  })(Teabag.Reporters.HTML.ProgressView);

  Teabag.Reporters.HTML.RadialProgressView = (function(_super) {

    __extends(RadialProgressView, _super);

    function RadialProgressView() {
      return RadialProgressView.__super__.constructor.apply(this, arguments);
    }

    RadialProgressView.supported = !!document.createElement("canvas").getContext;

    RadialProgressView.prototype.build = function() {
      this.el = this.createEl("div", "teabag-indicator radial-progress");
      return this.el.innerHTML = "<canvas id=\"teabag-progress-canvas\"></canvas>\n<em id=\"teabag-progress-percent\">0%</em>";
    };

    RadialProgressView.prototype.appendTo = function() {
      var canvas;
      RadialProgressView.__super__.appendTo.apply(this, arguments);
      this.size = 80;
      try {
        canvas = this.findEl("progress-canvas");
        canvas.width = canvas.height = canvas.style.width = canvas.style.height = this.size;
        this.ctx = canvas.getContext("2d");
        this.ctx.strokeStyle = "#fff";
        return this.ctx.lineWidth = 1.5;
      } catch (e) {

      }
    };

    RadialProgressView.prototype.update = function(total, run) {
      var half, percent;
      percent = total ? Math.ceil((run * 100) / total) : 0;
      this.setHtml("progress-percent", "" + percent + "%");
      if (!this.ctx) {
        return;
      }
      half = this.size / 2;
      this.ctx.clearRect(0, 0, this.size, this.size);
      this.ctx.beginPath();
      this.ctx.arc(half, half, half - 1, 0, Math.PI * 2 * (percent / 100), false);
      return this.ctx.stroke();
    };

    return RadialProgressView;

  })(Teabag.Reporters.HTML.ProgressView);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Teabag.Reporters.HTML.SpecView = (function(_super) {
    var viewId;

    __extends(SpecView, _super);

    viewId = 0;

    function SpecView(spec, reporter) {
      this.spec = spec;
      this.reporter = reporter;
      this.views = this.reporter.views;
      this.spec.viewId = viewId += 1;
      this.views.specs[this.spec.viewId] = this;
      SpecView.__super__.constructor.apply(this, arguments);
    }

    SpecView.prototype.build = function() {
      var classes;
      classes = ["spec"];
      if (this.spec.pending) {
        classes.push("state-pending");
      }
      SpecView.__super__.build.call(this, classes.join(" "));
      this.el.innerHTML = "<a href=\"" + this.spec.link + "\">" + this.spec.description + "</a>";
      this.parentView = this.buildParent();
      return this.parentView.append(this.el);
    };

    SpecView.prototype.buildParent = function() {
      var parent, view;
      parent = this.spec.parent;
      if (parent.viewId) {
        return this.views.suites[parent.viewId];
      } else {
        view = new Teabag.Reporters.HTML.SuiteView(parent, this.reporter);
        return this.views.suites[view.suite.viewId] = view;
      }
    };

    SpecView.prototype.buildErrors = function() {
      var div, error, html, _i, _len, _ref;
      div = this.createEl("div");
      html = "";
      _ref = this.spec.errors();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        error = _ref[_i];
        html += "<strong>" + (this.htmlSafe(error.message)) + "</strong><br/>" + (this.htmlSafe(error.stack || "Stack trace unavailable"));
      }
      div.innerHTML = html;
      return this.append(div);
    };

    SpecView.prototype.updateState = function(state, elapsed) {
      var classes, result, _base;
      result = this.spec.result();
      classes = ["state-" + state];
      if (elapsed > Teabag.slow) {
        classes.push("slow");
      }
      if (state !== "failed") {
        this.el.innerHTML += "<span>" + elapsed + "ms</span>";
      }
      this.el.className = classes.join(" ");
      if (result.status !== "passed") {
        this.buildErrors();
      }
      return typeof (_base = this.parentView).updateState === "function" ? _base.updateState(state) : void 0;
    };

    return SpecView;

  })(Teabag.Reporters.BaseView);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Teabag.Reporters.HTML.FailureView = (function(_super) {

    __extends(FailureView, _super);

    function FailureView(spec) {
      this.spec = spec;
      FailureView.__super__.constructor.apply(this, arguments);
    }

    FailureView.prototype.build = function() {
      var error, html, _i, _len, _ref;
      FailureView.__super__.build.call(this, "spec");
      html = "<h1 class=\"teabag-clearfix\"><a href=\"" + this.spec.link + "\">" + this.spec.fullDescription + "</a></h1>";
      _ref = this.spec.errors();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        error = _ref[_i];
        html += "<div><strong>" + (this.htmlSafe(error.message)) + "</strong><br/>" + (this.htmlSafe(error.stack || "Stack trace unavailable")) + "</div>";
      }
      return this.el.innerHTML = html;
    };

    return FailureView;

  })(Teabag.Reporters.BaseView);

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Teabag.Reporters.HTML.SuiteView = (function(_super) {
    var viewId;

    __extends(SuiteView, _super);

    viewId = 0;

    function SuiteView(suite, reporter) {
      this.suite = suite;
      this.reporter = reporter;
      this.views = this.reporter.views;
      this.suite.viewId = viewId += 1;
      this.views.suites[this.suite.viewId] = this;
      this.suite = new Teabag.Suite(suite);
      SuiteView.__super__.constructor.apply(this, arguments);
    }

    SuiteView.prototype.build = function() {
      SuiteView.__super__.build.call(this, "suite");
      this.el.innerHTML = "<h1><a href=\"" + this.suite.link + "\">" + this.suite.description + "</a></h1>";
      this.parentView = this.buildParent();
      return this.parentView.append(this.el);
    };

    SuiteView.prototype.buildParent = function() {
      var parent, view;
      parent = this.suite.parent;
      if (!parent) {
        return this.reporter;
      }
      if (parent.viewId) {
        return this.views.suites[parent.viewId];
      } else {
        view = new Teabag.Reporters.HTML.SuiteView(parent, this.reporter);
        return this.views.suites[view.suite.viewId] = view;
      }
    };

    SuiteView.prototype.append = function(el) {
      if (!this.ol) {
        SuiteView.__super__.append.call(this, this.ol = this.createEl("ol"));
      }
      return this.ol.appendChild(el);
    };

    SuiteView.prototype.updateState = function(state) {
      var _base;
      if (this.state === "failed") {
        return;
      }
      this.el.className = "" + (this.el.className.replace(/\s?state-\w+/, "")) + " state-" + state;
      if (typeof (_base = this.parentView).updateState === "function") {
        _base.updateState(state);
      }
      return this.state = state;
    };

    return SuiteView;

  })(Teabag.Reporters.BaseView);

}).call(this);
(function() {

  Teabag.Reporters.HTML.template = "<div class=\"teabag-clearfix\">\n  <div id=\"teabag-title\">\n    <h1><a href=\"\" id=\"teabag-root-link\">Teabag</a></h1>\n    <ul>\n      <li>version: <b id=\"teabag-version\"></b></li>\n      <li id=\"teabag-env-info\"></li>\n    </ul>\n  </div>\n  <div id=\"teabag-progress\"></div>\n  <ul id=\"teabag-stats\">\n    <li>passes: <b id=\"teabag-stats-passes\">0</b></li>\n    <li>failures: <b id=\"teabag-stats-failures\">0</b></li>\n    <li>skipped: <b id=\"teabag-stats-skipped\">0</b></li>\n    <li>duration: <b id=\"teabag-stats-duration\">&infin;</b></li>\n  </ul>\n</div>\n\n<div id=\"teabag-controls\" class=\"teabag-clearfix\">\n  <div id=\"teabag-toggles\">\n    <button id=\"teabag-use-catch\" title=\"Toggle using try/catch wrappers when possible\">Try/Catch</button>\n    <button id=\"teabag-build-full-report\" title=\"Toggle building the full report\">Full Report</button>\n    <button id=\"teabag-display-progress\" title=\"Toggle displaying progress as tests run\">Progress</button>\n  </div>\n  <div id=\"teabag-suites\"></div>\n</div>\n\n<hr/>\n\n<div id=\"teabag-filter\">\n  <h1>Filtering</h1>\n  <ul id=\"teabag-filter-list\"></ul>\n</div>\n\n<div id=\"teabag-report\">\n  <ol id=\"teabag-report-failures\"></ol>\n  <ol id=\"teabag-report-all\"></ol>\n</div>";

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Teabag.Reporters.Console = (function() {

    function Console() {
      this.reportRunnerResults = __bind(this.reportRunnerResults, this);
      this.start = new Teabag.Date();
      this.suites = {};
    }

    Console.prototype.reportRunnerStarting = function(runner) {
      return this.log({
        type: "runner",
        total: runner.total || (typeof runner.specs === "function" ? runner.specs().length : void 0) || 0,
        start: JSON.parse(JSON.stringify(this.start))
      });
    };

    Console.prototype.reportSuites = function() {
      var index, suite, _i, _len, _ref, _results;
      _ref = this.spec.getParents();
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        suite = _ref[index];
        if (this.suites[suite.fullDescription]) {
          continue;
        }
        this.suites[suite.fullDescription] = true;
        _results.push(this.log({
          type: "suite",
          label: suite.description,
          level: index
        }));
      }
      return _results;
    };

    Console.prototype.reportSpecResults = function(spec) {
      var result;
      this.spec = new Teabag.Spec(spec);
      result = this.spec.result();
      if (result.skipped) {
        return;
      }
      this.reportSuites();
      switch (result.status) {
        case "pending":
          return this.trackPending();
        case "failed":
          return this.trackFailure();
        default:
          return this.log({
            type: "spec",
            suite: this.spec.suiteName,
            label: this.spec.description,
            status: result.status,
            skipped: result.skipped
          });
      }
    };

    Console.prototype.trackPending = function() {
      var result;
      result = this.spec.result();
      return this.log({
        type: "spec",
        suite: this.spec.suiteName,
        label: this.spec.description,
        status: result.status,
        skipped: result.skipped
      });
    };

    Console.prototype.trackFailure = function() {
      var error, result, _i, _len, _ref, _results;
      result = this.spec.result();
      _ref = this.spec.errors();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        error = _ref[_i];
        _results.push(this.log({
          type: "spec",
          suite: this.spec.suiteName,
          label: this.spec.description,
          status: result.status,
          skipped: result.skipped,
          link: this.spec.fullDescription,
          message: error.message,
          trace: error.stack || error.message || "Stack Trace Unavailable"
        }));
      }
      return _results;
    };

    Console.prototype.reportRunnerResults = function() {
      this.log({
        type: "result",
        elapsed: ((new Teabag.Date().getTime() - this.start.getTime()) / 1000).toFixed(5),
        coverage: window.__coverage__
      });
      return Teabag.finished = true;
    };

    Console.prototype.log = function(obj) {
      if (obj == null) {
        obj = {};
      }
      obj["_teabag"] = true;
      return Teabag.log(JSON.stringify(obj));
    };

    return Console;

  })();

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Teabag.Reporters.Console = (function(_super) {

    __extends(Console, _super);

    function Console(env) {
      this.reportSpecResults = __bind(this.reportSpecResults, this);
      Console.__super__.constructor.apply(this, arguments);
      env.log(this.reportSpecResults);
      env.testDone(this.reportSpecResults);
      env.done(this.reportRunnerResults);
      this.reportRunnerStarting();
    }

    Console.prototype.reportRunnerStarting = function() {
      this.currentAssertions = [];
      return this.log({
        type: "runner",
        total: null,
        start: JSON.parse(JSON.stringify(this.start))
      });
    };

    Console.prototype.reportSpecResults = function(result) {
      if (typeof result.total !== "number") {
        this.currentAssertions.push(result);
        return;
      }
      result.assertions = this.currentAssertions;
      this.currentAssertions = [];
      return Console.__super__.reportSpecResults.call(this, result);
    };

    return Console;

  })(Teabag.Reporters.Console);

}).call(this);
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Teabag.Reporters.HTML = (function(_super) {

    __extends(HTML, _super);

    function HTML(env) {
      this.reportRunnerResults = __bind(this.reportRunnerResults, this);

      this.reportSpecResults = __bind(this.reportSpecResults, this);
      HTML.__super__.constructor.apply(this, arguments);
      env.log(this.reportSpecResults);
      env.testDone(this.reportSpecResults);
      env.done(this.reportRunnerResults);
      this.currentAssertions = [];
      this.reportRunnerStarting();
    }

    HTML.prototype.reportRunnerStarting = function() {
      this.total.exist = null;
      return this.setText("stats-duration", "...");
    };

    HTML.prototype.reportSpecResults = function(spec) {
      if (typeof spec.total !== "number") {
        this.currentAssertions.push(spec);
        return;
      }
      spec.assertions = this.currentAssertions;
      this.currentAssertions = [];
      this.reportSpecStarting(spec);
      return HTML.__super__.reportSpecResults.call(this, spec);
    };

    HTML.prototype.reportRunnerResults = function(result) {
      this.total.exist = this.total.run = result.total;
      return HTML.__super__.reportRunnerResults.apply(this, arguments);
    };

    HTML.prototype.readConfig = function() {
      HTML.__super__.readConfig.apply(this, arguments);
      return QUnit.config.notrycatch = this.config["use-catch"];
    };

    HTML.prototype.envInfo = function() {
      return "qunit 1.10.0";
    };

    return HTML;

  })(Teabag.Reporters.HTML);

  Teabag.Reporters.HTML.SpecView = (function(_super) {

    __extends(SpecView, _super);

    function SpecView() {
      return SpecView.__super__.constructor.apply(this, arguments);
    }

    SpecView.prototype.buildErrors = function() {
      var div, error, html, _i, _len, _ref;
      div = this.createEl("div");
      html = "";
      _ref = this.spec.errors();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        error = _ref[_i];
        html += "<strong>" + error.message + "</strong><br/>" + (this.htmlSafe(error.stack || "Stack trace unavailable")) + "<br/>";
      }
      div.innerHTML = html;
      return this.append(div);
    };

    SpecView.prototype.buildParent = function() {
      var parent, view;
      parent = this.spec.parent;
      if (!parent) {
        return this.reporter;
      }
      if (this.views.suites[parent.description]) {
        return this.views.suites[parent.description];
      } else {
        view = new Teabag.Reporters.HTML.SuiteView(parent, this.reporter);
        return this.views.suites[parent.description] = view;
      }
    };

    return SpecView;

  })(Teabag.Reporters.HTML.SpecView);

  Teabag.Reporters.HTML.FailureView = (function(_super) {

    __extends(FailureView, _super);

    function FailureView() {
      return FailureView.__super__.constructor.apply(this, arguments);
    }

    FailureView.prototype.build = function() {
      var error, html, _i, _len, _ref;
      FailureView.__super__.build.call(this, "spec");
      html = "<h1 class=\"teabag-clearfix\"><a href=\"" + this.spec.link + "\">" + this.spec.fullDescription + "</a></h1>";
      _ref = this.spec.errors();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        error = _ref[_i];
        html += "<div><strong>" + error.message + "</strong><br/>" + (this.htmlSafe(error.stack || "Stack trace unavailable")) + "</div>";
      }
      return this.el.innerHTML = html;
    };

    return FailureView;

  })(Teabag.Reporters.HTML.FailureView);

  Teabag.Reporters.HTML.SuiteView = (function(_super) {

    __extends(SuiteView, _super);

    function SuiteView(suite, reporter) {
      this.suite = suite;
      this.reporter = reporter;
      this.views = this.reporter.views;
      this.views.suites[this.suite.description] = this;
      this.build();
    }

    return SuiteView;

  })(Teabag.Reporters.HTML.SuiteView);

}).call(this);
(function() {
  var env, originalReset,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Teabag.Runner = (function(_super) {

    __extends(Runner, _super);

    function Runner() {
      Runner.__super__.constructor.apply(this, arguments);
      env.start();
    }

    Runner.prototype.setup = function() {
      return new (this.getReporter())(env);
    };

    return Runner;

  })(Teabag.Runner);

  Teabag.Spec = (function() {

    function Spec(spec) {
      this.spec = spec;
      this.fullDescription = "" + this.spec.module + " " + this.spec.name;
      this.description = "" + this.spec.name + " (" + this.spec.failed + ", " + this.spec.passed + ", " + this.spec.total + ")";
      this.link = "?grep=" + (encodeURIComponent("" + this.spec.module + ": " + this.spec.name));
      this.parent = this.spec.module ? new Teabag.Suite({
        description: this.spec.module
      }) : null;
      this.suiteName = this.spec.module;
      this.viewId = this.spec.viewId;
      this.pending = false;
    }

    Spec.prototype.errors = function() {
      var item, _i, _len, _ref, _results;
      if (!this.spec.failed) {
        return [];
      }
      _ref = this.spec.assertions;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        if (item.result) {
          continue;
        }
        _results.push({
          message: item.message,
          stack: item.source
        });
      }
      return _results;
    };

    Spec.prototype.getParents = function() {
      if (!this.parent) {
        return [];
      }
      return [this.parent];
    };

    Spec.prototype.result = function() {
      var status;
      status = "failed";
      if (!this.spec.failed) {
        status = "passed";
      }
      return {
        status: status,
        skipped: false
      };
    };

    return Spec;

  })();

  Teabag.Suite = (function() {

    function Suite(suite) {
      this.suite = suite;
      this.fullDescription = this.suite.description;
      this.description = this.suite.description;
      this.link = "?grep=" + (encodeURIComponent(this.fullDescription));
      this.parent = null;
    }

    return Suite;

  })();

  env = QUnit;

  env.config.autostart = false;

  env.config.altertitle = false;

  env.config.filter = Teabag.Runner.prototype.getParams()["grep"];

  window.fixture = Teabag.fixture;

  originalReset = env.reset;

  env.reset = function() {
    originalReset();
    return Teabag.fixture.cleanup();
  };

}).call(this);
