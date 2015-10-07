Teaspoon
========

[![Gem Version](https://img.shields.io/gem/v/teaspoon.svg)](https://rubygems.org/gems/teaspoon)
[![Dependency Status](https://gemnasium.com/modeset/teaspoon.svg)](https://gemnasium.com/modeset/teaspoon)
[![Build Status](https://img.shields.io/travis/modeset/teaspoon.svg)](https://travis-ci.org/modeset/teaspoon)
[![Code Climate](https://codeclimate.com/github/modeset/teaspoon/badges/gpa.svg)](https://codeclimate.com/github/modeset/teaspoon)
[![Test Coverage](https://codeclimate.com/github/modeset/teaspoon/badges/coverage.svg)](https://codeclimate.com/github/modeset/teaspoon)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

<img src="https://raw.github.com/modeset/teaspoon/master/screenshots/logo_big.png" alt="Logo by Morgan Keys" align="right" />
<sup>Logo by [Morgan Keys](http://www.morganrkeys.com/)</sup>

Teaspoon is a Javascript test runner built for Rails. It can run tests in the browser and headless using PhantomJS, Selenium WebDriver, or Capybara Webkit.

Feedback, ideas and pull requests are always welcome, or you can hit us up on Twitter @modeset_.

[![Join the chat at https://gitter.im/modeset/teaspoon](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/modeset/teaspoon?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The goal of Teaspoon is to stay simple while also providing the most complete Javascript testing solution for Rails.

Teaspoon takes advantage of the Rails asset pipeline, and ships with support for Jasmine, Mocha, and QUnit.

If you'd like to use Teaspoon with [Guard](https://github.com/guard/guard), check out the [guard-teaspoon](https://github.com/modeset/guard-teaspoon) project. Or, if you want to use the [Spring](https://github.com/rails/spring) preloader, try the unofficial [spring-commands-teaspoon](https://github.com/alejandrobabio/spring-commands-teaspoon).

## Screenshots

### Running in the console
![Console Reporter](https://raw.github.com/modeset/teaspoon/master/screenshots/console-reporter.png)

### Running in the console using [Tapout](https://github.com/rubyworks/tapout)
![Console Reporter Tapout](https://raw.github.com/modeset/teaspoon/master/screenshots/console-reporter-tapout.png)

### Running in the browser
![Browser Reporter](https://raw.github.com/modeset/teaspoon/master/screenshots/html-reporter.jpg)


## Table of Contents

1. [Installation](#installation)
2. [Usage](#usage)
3. [Writing Specs](#writing-specs)
4. [Fixtures](#fixtures)
5. [Suites](#suites)
6. [Coverage](#coverage)
7. [Configuration](#configuration)
8. [Test Frameworks](#test-frameworks)
9. [Support Libraries](#support-libraries)
10. [CI Support](#ci-support)


## Installation

Add the framework-specific Teaspoon gem to your Gemfile. In most cases you'll want to restrict it to the `:development, :test` groups. The available gems are `teaspoon-jasmine`, `teaspoon-mocha` and `teaspoon-qunit`. If you're unsure which framework you'd like to use, we think Jasmine is a good starting place.

```ruby
group :development, :test do
  gem "teaspoon-jasmine"
end
```

Run the install generator to get the environment file and a basic spec helper. If you want a CoffeeScript spec helper, you can tell the generator. Run the install generator with the `--help` flag for a list of available options.

```
rails generate teaspoon:install --coffee
```

To run Teaspoon headless you'll need PhantomJS, Selenium Webdriver or Capybara Webkit. We recommend PhantomJS, which you can install with homebrew, npm or [as a download](http://phantomjs.org/download.html).


## Usage

Teaspoon uses the Rails asset pipeline to serve files. This allows you to use `= require` in your test files, and allows you use things like HAML or RABL/JBuilder within your fixtures.

Here's a great [Quick Start Walkthrough](https://github.com/modeset/teaspoon/wiki/Quick-Start-Walkthrough) for writing and running your first tests.

You can run Teaspoon three ways -- in the browser, via the rake task, and using the command line interface (CLI).

### Browser

```
http://localhost:3000/teaspoon
```

### Rake

```
rake teaspoon
```

The rake task provides several ways of focusing tests. You can specify the suite to run, the files to run, directories to run, etc.

```
rake teaspoon suite=my_fantastic_suite
rake teaspoon files=spec/javascripts/integration,spec/javascripts/calculator_spec.js
rake teaspoon driver_options="—ssl-protocol=TLSv1 --ignore-ssl-errors=yes"
```

### CLI

```
bundle exec teaspoon
```

The CLI also provides several ways of focusing tests and is more full featured than the rake task. You can specify the suite to run, the files to run, directories to run, filters, etc.

```
bundle exec teaspoon --suite=my_fantastic_suite
bundle exec teaspoon spec/javascripts/integration spec/javascripts/calculator_spec.js
bundle exec teaspoon --filter="Calculator should add two digits"
```

Get full command line help:

```
bundle exec teaspoon --help
```

**Note:** The rake task and CLI run within the development environment for optimization unless otherwise specified.


## Writing Specs

Depending on which framework you use this can differ, and there's an expectation that you have a certain level of familiarity with your chosen test framework.

Teaspoon supports [Jasmine](http://pivotal.github.com/jasmine), [Mocha](https://github.com/mochajs/mocha) and [QUnit](http://qunitjs.com). And since it's possible to use the asset pipeline, feel free to use the `= require` directive throughout your specs and spec helpers.

Here's a basic spec written in Javascript using Jasmine:

```javascript
//= require jquery
describe("My great feature", function() {

  it("will change the world", function() {
    expect(true).toBe(true);
    expect(jQuery).toBeDefined();
  });

});
```

You can also check out the examples of a [Mocha Spec](https://github.com/modeset/teaspoon/wiki/Using-Mocha), and a [QUnit Test](https://github.com/modeset/teaspoon/wiki/Using-QUnit).

### Pending Specs

Every test framework is different, but we've tried to normalize some of those differences. For instance, Jasmine lacks the concept pending, while Mocha provides several ways to achieve this. So we thought it would be worth defining what is standard between the two frameworks. QUnit doesn't easily support the concept of pending, so that's not covered.

To mark a spec as pending in both Mocha and Jasmine, you can either not provide a function as the second argument to the `it` call, or you can use `xit` and `xdescribe`.

```javascript
describe("My great feature", function() {
  it("hasn't been tested yet");

  xit("has a test I can't figure out", function() {
    expect("complexity").to.be("easily testable");
  });

  xdescribe("A whole section that I've not gotten to", function() {
    it("hasn't been tested yet", function() {
      expect(true).to.be(false);
    });
  });
});
```

### Deferring Execution

Teaspoon allows deferring execution, which can be useful for asynchronous execution.

```javascript
Teaspoon.defer = true;
setTimeout(Teaspoon.execute, 1000); // defers execution for 1 second
```

### Using Require.js

There's a wiki article that goes into more depth on using [RequireJS with Teaspoon](https://github.com/modeset/teaspoon/wiki/RequireJS-with-Teaspoon). But in simple terms you can configure your suite to boot with RequireJS by setting the suite `boot_partial` directive to `"boot_require_js"`.

Be sure to require `require.js` in your spec helper. Teaspoon doesn't include it as a support library, so you'll need to provide your own.

```javascript
//= require require
```

Now require.js will be used to load all the specs in your suite, however, you'll still need to use require.js to pull down the dependencies as you would normally.

```javascript
define(['Model'], function (Model) {
  describe('Model', function () {
    // ...
  });
});
```


## Fixtures

Teaspoon ships with a fixture library that works with Jasmine, Mocha, and QUnit with minimal effort. It has a consistent API, and isn't dependent on jQuery.

The fixture path is configurable within Teaspoon, and the views will be rendered by a standard controller. This allows you to use things like RABL/JBuilder if you're building JSON, or HAML if you're building markup.

### Loading Files

Loading fixtures allows you to specify any number of files to load, and if they should be appended to the fixture element or replace what's currently there.

`fixture.load(url[, url, ...], append = false)` or `fixture(url[, url, ...], append = false)`

### Setting Manually

If you don't want to load files directly from the server you can provide strings instead of files, otherwise behaves like load.

`fixture.set(html[, html, ...], append = false)`

### Cleaning Up

You shouldn't have to cleanup (we do that for you based on your test framework), but if you need it.

`fixture.cleanup()`

### Preloading Files

Some test cases require stubbing Ajax requests, and in those cases you may want to preload the fixture files to cache them for later.  You can preload fixtures in your spec helper, or before you start mocking Ajax methods.

`fixture.preload(url[, url, ...])`

### Example Usage

```javascript
fixture.preload("fixture.html", "fixture.json"); // make the actual requests for the files
describe("Using fixtures", function() {
  fixture.set("<h2>Another Title</h2>"); // create some markup manually (will be in a beforeEach)

  beforeEach(function() {
    this.fixtures = fixture.load("fixture.html", "fixture.json", true); // append these fixtures which were already cached
  });

  it("loads fixtures", function() {
    expect($("h1", fixture.el).text()).toBe("Title") // using fixture.el as a jquery scope
    expect($("h2", fixture.el).text()).toBe("Another Title")
    expect(this.fixtures[0]).toBe(fixture.el) // the element is available as a return value and through fixture.el
    expect(this.fixtures[1]).toEqual(fixture.json[0]) // the json for json fixtures is returned, and available in fixture.json
  });
});
```

Check out some example of using fixtures with [Mocha](https://github.com/modeset/teaspoon/wiki/Using-Mocha), [QUnit](https://github.com/modeset/teaspoon/wiki/Using-QUnit).

**Note:** The element that Teaspoon creates is "#teaspoon-fixtures", in case you need to access it directly and put your own fixtures in manually.


## Suites

Teaspoon uses the concept of suites to group tests at a high level. These suites run in isolation and can have different configurations.

A default suite has been generated for you in your `teaspoon_env.rb`.

Suites inherit from a "default" suite. To modify this default, simply don't specify a name for the suite. In this example we're configuring the default, which all other suites will inherit from.

```ruby
config.suite do |suite|
  suite.helper = "other_spec_helper.js"
end
```

When defining a custom suite, provide a name and a block. The following example defines a suite named "my_suite".

```ruby
config.suite :my_suite do |suite|
  suite.helper = "my_spec_helper.js"
end
```

### Hooks

Hooks are designed to facilitate loading fixtures or other things that might be required on the back end before, after, or during running a suite or test.

You can define hooks in your suite configuration by specifying a name and a block. Hooks with the same name will be added to an array, and all configured hook callbacks with that name will be called when the hook is requested. If you don't specify a name, :default will be assumed.

```ruby
config.suite :my_suite do |suite|
  suite.hook :fixtures do
    # some code that would load your fixtures
  end

  suite.hook :setup do |arguments|
    # some code that has access to your passed in arguments
  end
end
```

Once hooks have been defined in your configuration, you can invoke them using the javascript `Teaspoon.hook` interface in your specs. A request will be sent to the server, where all blocks that have been specified for a given hook will be called in the order they were defined. Any arguments passed to `Teaspoon.hook` will be provided to the hooks defined in the configuration.

```js
Teaspoon.hook('fixtures')
Teaspoon.hook('setup', {foo: 'bar'})
```


## Coverage

Teaspoon uses [Istanbul](https://github.com/gotwarlost/istanbul) to generate code coverage statistics and reports. You can define coverage configurations the same way you define suites.

**Note:** Ensure that you are using Istanbul version `v0.3.0` or greater.

Each suite allows specifying ignored files, which allows you to ignore support libraries and dependencies.

The following configuration and example generates a text and cobertura report -- and an annotated HTML report that you can inspect further.

```ruby
config.coverage do |coverage|
  coverage.reports = ['text', 'html', 'cobertura']
end
```

```shell
bundle exec teaspoon --coverage=default
```

If you use the `"text"`, or `"text-summary"` reports, they will be output to the console after the tests have completed.

```
--------------------+-----------+-----------+-----------+-----------+
File                |   % Stmts |% Branches |   % Funcs |   % Lines |
--------------------+-----------+-----------+-----------+-----------+
  phantomjs/        |     93.75 |        75 |     94.12 |     93.65 |
    runner.js       |     93.75 |        75 |     94.12 |     93.65 |
--------------------+-----------+-----------+-----------+-----------+
All files           |     93.75 |        75 |     94.12 |     93.65 |
--------------------+-----------+-----------+-----------+-----------+
```

### Caveats

In order to provide accurate coverage and best performance, it is recommended that you require the implementation file directly from the spec file. For example:

```js
//= require "my_class"
describe("MyClass", function() { ... });
```

It is **not** recommended that you require the entirety of your assets from within your spec helper:

***spec_helper.js***
```js
//= require "application"
```

If you must require `application` from your spec helper and you have `expand_assets` configuration set to `false`, you'll need to exclude the spec helper from ignored coverage files:

***teaspoon_env.rb***
```ruby
config.coverage do |coverage|
  coverage.ignore = coverage.ignore.reject { |matcher| matcher.match('/spec_helper.') }
end
```

### Thresholds

Teaspoon allows defining coverage threshold requirements. If a threshold is not met, it will cause a test run failure.

This example would cause a failure if less than 50% of the statements were not covered by the tests for instance.

```ruby
config.coverage :CI do |coverage|
  coverage.statements = 50
  coverage.functions  = 50
  coverage.branches   = 50
  coverage.lines      = 50
end
```


## Configuration

When you install Teaspoon a `teaspoon_env.rb` file is generated that contains good documentation for each configuration directive. Otherwise you can get a refresher by checking the [Teaspoon Configuration](https://github.com/modeset/teaspoon/wiki/Teaspoon-Configuration) article.

**Note** If you want `teaspoon_env.rb` to live in a location other than the default install path, you can specify an alternate path in a `TEASPOON_ENV` environment variable (eg `$ TEASPOON_ENV=config/teaspoon.rb teaspoon`).


## Test Frameworks

[Jasmine](http://pivotal.github.com/jasmine) is one of the first BDD-style frameworks. We've been using Jasmine for a long time, and have been pretty happy with it. It lacks a few important things that could be in a test framework, so we've done a little bit of work to make that nicer. Like adding pending spec support.

[Mocha](http://visionmedia.github.com/mocha) came up while we were working on Teaspoon -- we read up about it and thought it was a pretty awesome library with some really great approaches to some of the things that some of us browser types should consider more often, so we included it and added support for it. We encourage you to give it a try. Read more about [Using Mocha](https://github.com/modeset/teaspoon/wiki/Using-Mocha) with Teaspoon.

[QUnit](http://qunitjs.com) We're not sure about how many people use QUnit, but we like jQuery, so we added it. Read more about [Using QUnit](https://github.com/modeset/teaspoon/wiki/Using-QUnit) with Teaspoon.

If you'd like to see what frameworks and versions Teaspoon supports, you can run `rake teaspoon:info`. The results of this will be restricted by what framework gems you have included in your Gemfile.


## Support Libraries

We know that testing usually requires more than just the test framework, so we've included some of the libraries that we use on a regular basis.

- [Sinon.JS](http://sinonjs.org) (1.8.2) Standalone test spies, stubs and mocks for JavaScript. No dependencies, works with any unit testing framework. BSD Licence.
- [ChaiJS](http://chaijs.com/) (1.8.1) BDD / TDD assertion library for node and the browser that can be delightfully paired with any javascript testing framework. MIT License.
- [Chai-jQ](http://formidablelabs.github.io/chai-jq/) (0.0.7) An alternate plugin for the Chai assertion library to provide jQuery-specific assertions. MIT License.
- [Sinon-Chai](https://github.com/domenic/sinon-chai) (1.0.0) Extends Chai with assertions for the Sinon.JS mocking framework. MIT-ish License.
- [expect.js](https://github.com/LearnBoost/expect.js) (0.1.2) Minimalistic BDD assertion toolkit based on should.js. MIT License.
- [jasmine-jquery-1.7.0.js](https://github.com/velesin/jasmine-jquery) (1.7.0) For Jasmine v1, A set of custom matchers for jQuery, and an API for handling HTML fixtures in your specs. MIT License.
- [jasmine-jquery-2.0.0.js](https://github.com/velesin/jasmine-jquery) (2.0.0) For Jasmine v2, A set of custom matchers for jQuery, and an API for handling HTML fixtures in your specs. MIT License.

You can require the various support files in your spec helper by using:

```javascript
//= require support/sinon
//= require support/chai
//= require support/chai-1.10.0
//= require support/sinon-chai
//= require support/expect
//= require support/jasmine-jquery-1.7.0
//= require support/jasmine-jquery-2.0.0
```


## CI Support

Teaspoon works great on CI setups, and we've spent a good amount of time on getting that good. There's a lot of information to go over with that topic, but here are some highlights.

Add a line to execute Teaspoon (e.g. `bundle exec teaspoon`) in your CI config file. If you're using TravisCI or CircleCI it just works, but if you're using something else all you should need is to ensure PhantomJS is installed.

Alternately, you can add Teaspoon to the default rake tasks by clearing out the defaults (not always required), and then add `:teaspoon` into the chain of tasks where you want.

```ruby
Rake::Task['default'].prerequisites.clear
Rake::Task['default'].clear

task default: [:spec, :teaspoon, :cucumber]
```

Some build services also support selenium based setups using Xvfb and Firefox. This works well on on TravisCI, and we've heard of some success doing this on CircleCI, however if you are experiencing timeouts try to add a post-dependency command to precompile your assets (eg. `rake assets:precompile`.

If you want to generate reports that CI can use you can install Istanbul for coverage reports -- and output the report using the cobertura format, which Hudson and some others can read. You can track spec failure rates by using the tap formatter, or on TeamCity setups you can use the teamcity formatter. A junit formatter is available as well.

We encourage you to experiment and let us know. Feel free to create a wiki article about what you did to get it working on your CI setup.


## Alternative Projects

[Konacha](https://github.com/jfirebaugh/konacha)
[Jasminerice](https://github.com/bradphelan/jasminerice)
[Evergreen](https://github.com/abepetrillo/evergreen)
[jasmine-rails](https://github.com/searls/jasmine-rails)
[guard-jasmine](https://github.com/netzpirat/guard-jasmine)


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)

Copyright 2014 [Mode Set](https://github.com/modeset)

All licenses for the bundled Javascript libraries are included (MIT/BSD).


## Make Code Not War
![crest](https://secure.gravatar.com/avatar/aa8ea677b07f626479fd280049b0e19f?s=75)
