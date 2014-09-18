/*!
 * chai-jq
 * -------
 * An alternate jQuery assertion library for Chai.
 */
(function () {
  var root = this;

  /*!
   * Chai jQuery plugin implementation.
   */
  function chaiJq(chai, utils) {
    "use strict";

    // ------------------------------------------------------------------------
    // Variables
    // ------------------------------------------------------------------------
    var flag = utils.flag,
      toString = Object.prototype.toString;

    // ------------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------------
    /*!
     * Give a more useful element name.
     */
    var _elName = function ($el) {
      var name = "",
        id = $el.attr("id"),
        cls = $el.attr("class") || "";

      // Try CSS selector id.
      if (id) {
        name += "#" + id;
      }
      if (cls) {
        name += "." + cls.split(" ").join(".");
      }
      if (name) {
        return "'" + name + "'";
      }

      // Give up.
      return $el;
    };

    // ------------------------------------------------------------------------
    // Type Inference
    //
    // (Inspired by Underscore)
    // ------------------------------------------------------------------------
    var _isRegExp = function (val) {
      return toString.call(val) === "[object RegExp]";
    };

    // ------------------------------------------------------------------------
    // Comparisons
    // ------------------------------------------------------------------------
    var _equals = function (exp, act) {
      return exp === act;
    };

    var _contains = function (exp, act) {
      return act.indexOf(exp) !== -1;
    };

    var _exists = function (exp, act) {
      return act !== undefined;
    };

    var _regExpMatch = function (expRe, act) {
      return expRe.exec(act);
    };

    // ------------------------------------------------------------------------
    // Assertions (Internal)
    // ------------------------------------------------------------------------
    /*!
     * Wrap assert function and add properties.
     */
    var _jqAssert = function (fn) {
      return function (exp, msg) {
        // Set properties.
        this._$el = flag(this, "object");
        this._name = _elName(this._$el);

        // Flag message.
        if (msg) {
          flag(this, "message", msg);
        }

        // Invoke assertion function.
        fn.apply(this, arguments);
      };
    };

    /*!
     * Base for the boolean is("selector") method call.
     *
     * @see http://api.jquery.com/is/]
     *
     * @param {String} selector jQuery selector to match against
     */
    var _isMethod = function (jqSelector) {
      // Make selector human readable.
      var selectorDesc = jqSelector.replace(/:/g, "");

      // Return decorated assert.
      return _jqAssert(function () {
        this.assert(
          this._$el.is(jqSelector),
          "expected " + this._name + " to be " + selectorDesc,
          "expected " + this._name + " to not be " + selectorDesc
        );
      });
    };

    /*!
     * Abstract base for a "containable" method call.
     *
     * @param {String} jQuery           method name.
     * @param {Object} opts             options
     * @param {String} opts.hasArg      takes argument for method
     * @param {String} opts.isProperty  switch assert context to property if no
     *                                  expected val
     * @param {String} opts.hasContains is "contains" applicable
     * @param {String} opts.altGet      alternate function to get value if none
     */
    var _containMethod = function (jqMeth, opts) {
      // Unpack options.
      opts || (opts = {});
      opts.hasArg       = !!opts.hasArg;
      opts.isProperty   = !!opts.isProperty;
      opts.hasContains  = !!opts.hasContains;
      opts.defaultAct   = undefined;

      // Return decorated assert.
      return _jqAssert(function () {
        // Arguments.
        var exp = arguments[opts.hasArg ? 1 : 0],
          arg = opts.hasArg ? arguments[0] : undefined,

          // Switch context to property / check mere presence.
          noExp = arguments.length === (opts.hasArg ? 1 : 0),
          isProp = opts.isProperty && noExp,

          // Method.
          act = (opts.hasArg ? this._$el[jqMeth](arg) : this._$el[jqMeth]()),
          meth = opts.hasArg ? jqMeth + "('" + arg + "')" : jqMeth,

          // Assertion type.
          contains = !isProp && opts.hasContains && flag(this, "contains"),
          have = contains ? "contain" : "have",
          comp = _equals;

        // Set comparison.
        if (isProp) {
          comp = _exists;
        } else if (contains) {
          comp = _contains;
        }

        // Second chance getter.
        if (opts.altGet && !act) {
          act = opts.altGet(this._$el, arg);
        }

        // Default actual value on undefined.
        if (typeof act === "undefined") {
          act = opts.defaultAct;
        }

        // Same context assertion.
        this.assert(
          comp(exp, act),
          "expected " + this._name + " to " + have + " " + meth +
            (isProp ? "" : " #{exp} but found #{act}"),
          "expected " + this._name + " not to " + have + " " + meth +
            (isProp ? "" : " #{exp}"),
          exp,
          act
        );

        // Change context if property and not negated.
        if (isProp && !flag(this, "negate")) {
          flag(this, "object", act);
        }
      });
    };

    // ------------------------------------------------------------------------
    // API
    // ------------------------------------------------------------------------

    /**
     * Asserts that the element is visible.
     *
     * *Node.js/JsDom Note*: JsDom does not currently infer zero-sized or
     * hidden parent elements as hidden / visible appropriately.
     *
     * ```js
     * expect($("<div>&nbsp;</div>"))
     *   .to.be.$visible;
     * ```
     *
     * @see http://api.jquery.com/visible-selector/
     *
     * @api public
     */
    var $visible = _isMethod(":visible");

    chai.Assertion.addProperty("$visible", $visible);

    /**
     * Asserts that the element is hidden.
     *
     * *Node.js/JsDom Note*: JsDom does not currently infer zero-sized or
     * hidden parent elements as hidden / visible appropriately.
     *
     * ```js
     * expect($("<div style=\"display: none\" />"))
     *   .to.be.$hidden;
     * ```
     *
     * @see http://api.jquery.com/hidden-selector/
     *
     * @api public
     */
    var $hidden = _isMethod(":hidden");

    chai.Assertion.addProperty("$hidden", $hidden);

    /**
     * Asserts that the element value matches a string or regular expression.
     *
     * ```js
     * expect($("<input value='foo' />"))
     *   .to.have.$val("foo").and
     *   .to.have.$val(/^foo/);
     * ```
     *
     * @see http://api.jquery.com/val/
     *
     * @param {String|RegExp} expected  value
     * @param {String}        message   failure message (_optional_)
     * @api public
     */
    var $val = _jqAssert(function (exp) {
      var act = this._$el.val(),
        comp = _isRegExp(exp) ? _regExpMatch : _equals;

      this.assert(
        comp(exp, act),
        "expected " + this._name + " to have val #{exp} but found #{act}",
        "expected " + this._name + " not to have val #{exp}",
        exp,
        typeof act === "undefined" ? "undefined" : act
      );
    });

    chai.Assertion.addMethod("$val", $val);

    /**
     * Asserts that the element has a class match.
     *
     * ```js
     * expect($("<div class='foo bar' />"))
     *   .to.have.$class("foo").and
     *   .to.have.$class("bar");
     * ```
     *
     * @see http://api.jquery.com/hasClass/
     *
     * @param {String} expected class name
     * @param {String} message  failure message (_optional_)
     * @api public
     */
    var $class = _jqAssert(function (exp) {
      var act = this._$el.attr("class") || "";

      this.assert(
        this._$el.hasClass(exp),
        "expected " + this._name + " to have class #{exp} but found #{act}",
        "expected " + this._name + " not to have class #{exp}",
        exp,
        act
      );
    });

    chai.Assertion.addMethod("$class", $class);

    /**
     * Asserts that the target has exactly the given named attribute, or
     * asserts the target contains a subset of the attribute when using the
     * `include` or `contain` modifiers.
     *
     * ```js
     * expect($("<div id=\"hi\" foo=\"bar time\" />"))
     *   .to.have.$attr("id", "hi").and
     *   .to.contain.$attr("foo", "bar");
     * ```
     *
     * Changes context to attribute string *value* when no expected value is
     * provided:
     *
     * ```js
     * expect($("<div id=\"hi\" foo=\"bar time\" />"))
     *   .to.have.$attr("foo").and
     *     .to.equal("bar time").and
     *     .to.match(/^b/);
     * ```
     *
     * @see http://api.jquery.com/attr/
     *
     * @param {String} name     attribute name
     * @param {String} expected attribute content (_optional_)
     * @param {String} message  failure message (_optional_)
     * @returns current object or attribute string value
     * @api public
     */
    var $attr = _containMethod("attr", {
      hasArg: true,
      hasContains: true,
      isProperty: true
    });

    chai.Assertion.addMethod("$attr", $attr);

    /**
     * Asserts that the target has exactly the given named
     * data-attribute, or asserts the target contains a subset
     * of the data-attribute when using the
     * `include` or `contain` modifiers.
     *
     * ```js
     * expect($("<div data-id=\"hi\" data-foo=\"bar time\" />"))
     *   .to.have.$data("id", "hi").and
     *   .to.contain.$data("foo", "bar");
     * ```
     *
     * Changes context to data-attribute string *value* when no
     * expected value is provided:
     *
     * ```js
     * expect($("<div data-id=\"hi\" data-foo=\"bar time\" />"))
     *   .to.have.$data("foo").and
     *     .to.equal("bar time").and
     *     .to.match(/^b/);
     * ```
     *
     * @see http://api.jquery.com/data/
     *
     * @param {String} name     data-attribute name
     * @param {String} expected data-attribute content (_optional_)
     * @param {String} message  failure message (_optional_)
     * @returns current object or attribute string value
     * @api public
     */
    var $data = _containMethod("data", {
      hasArg: true,
      hasContains: true,
      isProperty: true
    });

    chai.Assertion.addMethod("$data", $data);

    /**
     * Asserts that the target has exactly the given named property.
     *
     * ```js
     * expect($("<input type=\"checkbox\" checked=\"checked\" />"))
     *   .to.have.$prop("checked", true).and
     *   .to.have.$prop("type", "checkbox");
     * ```
     *
     * Changes context to property string *value* when no expected value is
     * provided:
     *
     * ```js
     * expect($("<input type=\"checkbox\" checked=\"checked\" />"))
     *   .to.have.$prop("type").and
     *     .to.equal("checkbox").and
     *     .to.match(/^c.*x$/);
     * ```
     *
     * @see http://api.jquery.com/prop/
     *
     * @param {String} name     property name
     * @param {Object} expected property value (_optional_)
     * @param {String} message  failure message (_optional_)
     * @returns current object or property string value
     * @api public
     */
    var $prop = _containMethod("prop", {
      hasArg: true,
      isProperty: true
    });

    chai.Assertion.addMethod("$prop", $prop);

    /**
     * Asserts that the target has exactly the given HTML, or
     * asserts the target contains a subset of the HTML when using the
     * `include` or `contain` modifiers.
     *
     * ```js
     * expect($("<div><span>foo</span></div>"))
     *   .to.have.$html("<span>foo</span>").and
     *   .to.contain.$html("foo");
     * ```
     *
     * @see http://api.jquery.com/html/
     *
     * @param {String} expected HTML content
     * @param {String} message  failure message (_optional_)
     * @api public
     */
    var $html = _containMethod("html", {
      hasContains: true
    });

    chai.Assertion.addMethod("$html", $html);

    /**
     * Asserts that the target has exactly the given text, or
     * asserts the target contains a subset of the text when using the
     * `include` or `contain` modifiers.
     *
     * ```js
     * expect($("<div><span>foo</span> bar</div>"))
     *   .to.have.$text("foo bar").and
     *   .to.contain.$text("foo");
     * ```
     *
     * @see http://api.jquery.com/text/
     *
     * @name $text
     * @param {String} expected text content
     * @param {String} message  failure message (_optional_)
     * @api public
     */
    var $text = _containMethod("text", {
      hasContains: true
    });

    chai.Assertion.addMethod("$text", $text);

    /**
     * Asserts that the target has exactly the given CSS property, or
     * asserts the target contains a subset of the CSS when using the
     * `include` or `contain` modifiers.
     *
     * *Node.js/JsDom Note*: Computed CSS properties are not correctly
     * inferred as of JsDom v0.8.8. Explicit ones should get matched exactly.
     *
     * *Browser Note*: Explicit CSS properties are sometimes not matched
     * (in contrast to Node.js), so the plugin performs an extra check against
     * explicit `style` properties for a match. May still have other wonky
     * corner cases.
     *
     * *PhantomJS Note*: PhantomJS also is fairly wonky and unpredictable with
     * respect to CSS / styles, especially those that come from CSS classes
     * and not explicity `style` attributes.
     *
     * ```js
     * expect($("<div style=\"width: 50px; border: 1px dotted black;\" />"))
     *   .to.have.$css("width", "50px").and
     *   .to.have.$css("border-top-style", "dotted");
     * ```
     *
     * @see http://api.jquery.com/css/
     *
     * @name $css
     * @param {String} expected CSS property content
     * @param {String} message  failure message (_optional_)
     * @api public
     */
    var $css = _containMethod("css", {
      hasArg: true,
      hasContains: true,

      // Alternate Getter: If no match, go for explicit property.
      altGet: function ($el, prop) { return $el.prop("style")[prop]; }
    });

    chai.Assertion.addMethod("$css", $css);
  }

  /*!
   * Wrap AMD, etc. using boilerplate.
   */
  function wrap(plugin) {
    "use strict";
    /* global module:false, define:false */

    if (typeof require === "function" &&
        typeof exports === "object" &&
        typeof module  === "object") {
      // NodeJS
      module.exports = plugin;

    } else if (typeof define === "function" && define.amd) {
      // AMD: Assumes importing `chai` and `jquery`. Returns a function to
      //      inject with `chai.use()`.
      //
      // See: https://github.com/chaijs/chai-jquery/issues/27
      define(["jquery"], function ($) {
        return function (chai, utils) {
          return plugin(chai, utils, $);
        };
      });

    } else {
      // Other environment (usually <script> tag): plug in to global chai
      // instance directly.
      root.chai.use(function (chai, utils) {
        return plugin(chai, utils, root.jQuery);
      });
    }
  }

  // Hook it all together.
  wrap(chaiJq);
}());
