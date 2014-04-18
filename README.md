Teaspoon
========

[![Gem Version](https://img.shields.io/gem/v/teaspoon.svg)](http://badge.fury.io/rb/teaspoon)
[![Dependency Status](https://img.shields.io/gemnasium/modeset/teaspoon.svg)](https://gemnasium.com/modeset/teaspoon)
[![Build Status](https://img.shields.io/travis/modeset/teaspoon.svg)](https://travis-ci.org/modeset/teaspoon)
[![Code Climate](https://img.shields.io/codeclimate/github/modeset/teaspoon.svg)](https://codeclimate.com/github/modeset/teaspoon)
[![Coverage Status](https://img.shields.io/coveralls/modeset/teaspoon/master.svg)](https://coveralls.io/r/modeset/teaspoon?branch=master)

<img src="https://raw.github.com/modeset/teaspoon/master/screenshots/logo_big.png" alt="Logo by Morgan Keys" align="right" />
<sup>Logo by [Morgan Keys](http://www.morganrkeys.com/)</sup>

Teaspoon is a Javascript test runner built for Rails. It runs tests in the browser or headless using PhantomJS or Selenium WebDriver.

The goal is to be simple, while still providing the most complete Javascript testing solution for Rails.

Teaspoon takes advantage of the asset pipeline. And ships with support for Jasmine, Mocha, and QUnit.

Ok, another Javascript test runner, right? Yeah, that's tough, but we're pretty confident Teaspoon is one of the nicest and most full featured you'll find at the moment. And if you disagree, let us know and we'll likely fix whatever it is that you didn't like.

Feedback, ideas and pull requests are always welcome, or you can hit us up on Twitter @modeset_.

If you'd like to use Teaspoon with [Guard](https://github.com/guard/guard), check out the [guard-teaspoon](https://github.com/modeset/guard-teaspoon) project.

Or, if you'd want to use [Spring](https://github.com/rails/spring) preloader, use with  [spring-commands-teaspoon](https://github.com/alejandrobabio/spring-commands-teaspoon).

## Developer Notice

The master branch deviates heavily from 0.7.9 and represents the changes that will be in 0.8. There's a good [wiki article](https://github.com/modeset/teaspoon/wiki/Changelog) about the notable changes and how you can ease the pain of upgrading.

While we know that considerable changes like these can be a pain, they're not made frivolously, and they set the groundwork for what we can all build on and contribute to. There was some cleanup that needed to happen, and some polish, and in that process we tried to think about what we've learned thus far, and how we can better that for future versions. We appreciate your tolerance and willingness to help us fix anything that we missed.

:heart:

### 0.8.0 - follow ups / todo

Here's a short list of things that 0.8.0 might also address.

- add jasmine2 support
- tests for the require js stuff (this is brittle and since we don't use requirejs, intrinsically hard)
- hooks could be improved to specify method (get/post), and to pass params -- passing to the blocks if they have arity

#### nice to haves

- a more useful rake task library (like rspec https://www.relishapp.com/rspec/rspec-core/docs/command-line/rake-task)
- rspec interface, so rspec reporters can be used


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

Add it to your Gemfile. In most cases you'll want to restrict it to the `:development, :test` groups.

```ruby
group :development, :test do
  gem "teaspoon"
end
```

Run the install generator to get the environment file and a basic spec helper. You can tell the generator which framework you want to use, if you want a coffeescript spec helper, etc. Run the install generator with the `--help` flag for a list of available options.

```
rails generate teaspoon:install --framework=mocha --coffee
```

To run Teaspoon headless you'll need Selenium Webdriver or PhantomJS. We recommend PhantomJS, which you can install with homebrew, npm or [as a download](http://phantomjs.org/download.html).

```
brew install phantomjs
- OR -
npm install -g phantomjs
```

The PhantomJS binary will be used by default if it's available in your path, otherwise you can use the gem as a fallback.

```ruby
group :development, :test do
  gem "teaspoon"
  gem "phantomjs", ">= 1.8.1.1" # this is optional if the phantomjs binary is installed (as of teaspoon 0.7.9)
end
```

### Upgrading

We made some changes to how configuration and loading works for version 0.8.0, which might cause some confusion. For this we're sorry, but it'll be better in the long run -- and hey, on the up side, we didn't write a javascript test runner and then abandon it.

1. backup your `spec/teaspoon_env.rb` file.
2. run the install generator to get the new `teaspoon_env.rb`.
3. migrate your old settings into the new file, noting the changes that might exist.
4. move all settings that you had in `config/initializers/teaspoon.rb` into `spec/teaspoon_env.rb` and delete the initializer.


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
```

### CLI

```
bundle exec teaspoon
```

The CLI also provides several ways of focusing tests. You can specify the suite to run, the files to run, directories to run, filters, etc.

```
bundle exec teaspoon --suite=my_fantastic_suite
bundle exec teaspoon spec/javascripts/integration spec/javascripts/calculator_spec.js
bundle exec teaspoon --filter="Calculator should add two digits"
```

Get full command line help:

```
bundle exec teaspoon --help
```

**Note:** The rake task and CLI run within the development environment unless otherwise specified.


## Writing Specs

Depending on which framework you use this can differ, and there's an expectation that you have a certain level of familiarity with your chosen test framework.

Teaspoon supports [Jasmine](http://pivotal.github.com/jasmine), [Mocha](http://visionmedia.github.com/mocha) and [QUnit](http://qunitjs.com). And since it's possible to use the asset pipeline, feel free to use the `= require` directive throughout your specs and spec helpers.

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
setTimeout(Teaspoon.execute, 1000); // defers execution for 1 second as an example
```

### Using Require.js

You can configure your suite to boot with require.js by setting the suite `boot_partial` directive to `"boot_require_js"`.

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

Teaspoon ships with a fixture library that works with Jasmine, Mocha, and QUnit with a minimum of effort, has a nice consistent API, and isn't dependent on jQuery.

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

**Note:** The element that Teaspoon creates is "#teaspoon-fixtures", in case you need to access it directly.


## Suites

Teaspoon uses the concept of suites to group tests at a high level. These suites run in isolation and can have different configurations.

A default suite has been generated for you in your `teaspoon_env.rb`.

Suites inherit from a "default" suite. To modify the "default" suite simply don't specify a name for the suite. In this example we're configuring the default suite, which all other suites will inherit from.

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

Hooks are designed to facilitate loading fixtures or other things that might be required on the back end before, after, or during running a suite or test. You can define hooks in your suite by specifying a name and a block. Hooks with the same name will be added to an array, and all will be called when the hook is requested. If you don't specify a name, :default will be assumed.

```ruby
config.suite :my_suite do |suite|
  suite.hook :fixtures do
    # some code that would load your fixtures
  end
end
```

You can then use the javascript `Teaspoon.hook("fixtures")` call at the beginning of a suite run or similar. All blocks that have been specified for a given hook will be called in the order they were defined.

### Manifest Style

Teaspoon is happy to look for files for you (and this is recommended), but you can disable this feature and maintain a manifest yourself. Configure the suite to not match any files, and then use your spec helper to create your manifest.

```ruby
config.suite do |suite|
  suite.matcher = nil
  suite.helper = "spec_manifest"
end
```

**Note:** This limits your ability to run specific files from the command line interface and other benefits, and so isn't recommended.


## Coverage

Teaspoon uses [Istanbul](https://github.com/gotwarlost/istanbul) to generate code coverage statistics and reports. You can define coverage configurations the same way you define suites.

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

When you install Teaspoon a `teaspoon_env.rb` file is generated that contains most of this information, but we've provided it here too.

<dl>

<dt> mount_at </dt><dd>
  Determines where the Teaspoon routes will be mounted. Changing this to "/jasmine" would allow you to browse to <code>http://localhost:3000/jasmine</code> to run your tests.<br/><br/>

  <b>default:</b> <code>"/teaspoon"</code>
</dd>

<dt> root </dt><dd>
  Specifies the root where Teaspoon will look for files. If you're testing an engine using a dummy application it can be useful to set this to your engines root (e.g. <code>Teaspoon::Engine.root</code>).<br/>
  <b>Note:</b> Defaults to <code>Rails.root</code> if nil.<br/><br/>

  <b>default:</b> <code>nil</code>
</dd>

<dt> asset_paths </dt><dd>
  Paths that will be appended to the Rails assets paths.<br/>
  <b>Note:</b> Relative to <code>config.root</code>.<br/><br/>

  <b>default:</b> <code>["spec/javascripts", "spec/javascripts/stylesheets", "test/javascripts", "test/javascripts/stylesheets"]</code>
</dd>

<dt> fixture_paths </dt><dd>
  Fixtures are rendered through a controller, which allows using HAML, RABL/JBuilder, etc. Files in this path will be rendered as fixtures.<br/><br/>

  <b>default:</b> <code>["spec/javascripts/fixtures", "test/javascripts/fixtures"]</code>
</dd>

</dl>

### Suite Configuration Directives

<dl>

<dt> use_framework(name[, version]) </dt><dd>
  Specify the framework and optionally version you would like to use. This will do some basic setup for you -- which you can override with the directives below. This should be specified first, as it can override other directives.<br/><br/>
  <b>Note:</b> If no version is specified, the latest is assumed.<br/><br/>

  <b>available:</b> jasmine[1.3.1, 2.0.0], mocha[1.10.0, 1.17.1] qunit[1.12.0, 1.14.0]<br/>
  <b>default:</b> <code>[no default]</code>
</dd>

<dt> matcher </dt><dd>
  Specify a file matcher as a regular expression and all matching files will be loaded when the suite is run. These files need to be within an asset path. You can add asset paths using the `config.asset_paths`.<br/>
  <b>Note:</b> Can be set to <code>nil</code> to match no files.<br/><br/>

  <b>default:</b> <code>"{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"</code>
</dd>

<dt> helper </dt><dd>
  This suites spec helper, which can require additional support files. This file is loaded before any of your test files are loaded.<br/><br/>

  <b>default:</b> <code>"spec_helper"</code>
</dd>

<dt> javascripts </dt><dd>
  The core Teaspoon javascripts. If you're using the `use_framework` directive this will be set based on that, but it can be useful to provide an override to use a custom version of a test framework.<br/>
  <b>Note:</b> It's recommended to only include the core files here, as you can require support libraries from your spec helper.<br/>
  <b>Note:</b> For CoffeeScript files use <code>"teaspoon/jasmine"</code> etc.<br/><br/>

  <b>available:</b> teaspoon-jasmine, teaspoon-mocha, teaspoon-qunit<br/>
  <b>default:</b> <code>["jasmine/1.3.1", "teaspoon-jasmine"]</code>
</dd>

<dt> stylesheets </dt><dd>
  You can include your own stylesheets if you want to change how Teaspoon looks.<br/>
  <b>Note:</b> Spec related CSS can and should be loaded using fixtures.<br/><br/>

  <b>default:</b> <code>["teaspoon"]</code>
</dd>

<dt> boot_partial </dt><dd>
  Partial to be rendered in the head tag of the runner. You can use the provided ones or define your own by creating a `_boot.html.erb` in your fixtures path, and adjust the config to `"/boot"` for instance.<br/><br/>

  <b>available:</b> boot, boot_require_js<br/>
  <b>default:</b> <code>"boot"</code>
</dd>

<dt> normalize_asset_path </dt><dd>
  When using custom file-extensions you might need to supply a custom asset path normalization. If you need to match a
  custom extension, simply supply a custom lambda/proc that returns the desired filename.<br/><br/>

  <b>default:</b> <code>`filename.gsub('.erb', '').gsub(/(\.js\.coffee|\.coffee)$/, ".js")`</code>
</dd>

</dl>


## Configuration

The best way to read about the configuration options is to generate the initializer and env, but we've included the info here as well.

<dt> body_partial </dt><dd>
  Partial to be rendered in the body tag of the runner. You can define your own to create a custom body structure.<br/><br/>

  <b>default:</b> <code>"body"</code>
</dd>

<dt> no_coverage </dt><dd>
  Assets to be ignored when generating coverage reports. Accepts an array of filenames or regular expressions. The default excludes assets from vendor, gems and support libraries.<br/><br/>

  <b>default:</b> <code>[%r{/lib/ruby/gems/}, %r{/vendor/assets/}, %r{/support/}, %r{/(.+)_helper.}]</code>
</dd>

<dt> hook(name, &block) </dt><dd>
  Hooks allow you to use `Teaspoon.hook("fixtures")` before, after, or during your spec run. This will make a synchronous Ajax request to the server that will call all of the blocks you've defined for that hook name. (e.g. <code>suite.hook :fixtures, proc{ }</code>)

  <b>default:</b> <code>Hash.new{ |h, k| h[k] = [] }</code>
</dd>

</dl>

### Console Runner Specific

These configuration directives are applicable only when running via the rake task or command line interface. These directives can be overridden using the command line interface arguments or with ENV variables when using the rake task.

<dl>

<dt> driver </dt><dd>
  Specify which headless driver to use. Supports <a href="http://phantomjs.org">PhantomJS</a> and <a href="http://seleniumhq.org/docs/03_webdriver.jsp">Selenium Webdriver</a>.<br/><br/>

  <a href="https://github.com/modeset/teaspoon/wiki/Using-PhantomJS">Using PhantomJS</a>.<br/>
  <a href="https://github.com/modeset/teaspoon/wiki/Using-Selenium-WebDriver">Using Selenium WebDriver</a><br/><br/>

  <b>available:</b> phantomjs, selenium<br/>
  <b>default:</b> <code>"phantomjs"</code>

  <ul>
    <li>CLI: -d, --driver DRIVER</li>
    <li>ENV: DRIVER=[DRIVER]</li>
  </ul>
</dd>

<dt> driver_options </dt><dd>
  Specify additional options/switches for the driver.<br/><br/>

  <a href="https://github.com/modeset/teaspoon/wiki/Using-PhantomJS">Using PhantomJS</a>.<br/>
  <a href="https://github.com/modeset/teaspoon/wiki/Using-Selenium-WebDriver">Using Selenium WebDriver</a><br/><br/>

  <b>default:</b> <code>nil</code>

  <ul>
    <li>CLI: --driver-options OPTIONS</li>
    <li>ENV: DRIVER_OPTIONS=[OPTIONS]</li>
  </ul>
</dd>

<dt> driver_timeout </dt><dd>
  Specify the timeout for the driver. Specs are expected to complete within this time frame or the run will be considered a failure. This is to avoid issues that can arise where tests stall.<br/><br/>

  <b>default:</b> <code>180</code>

  <ul>
    <li>CLI: --driver-timeout SECONDS</li>
    <li>ENV: DRIVER_TIMEOUT=[SECONDS]</li>
  </ul>
</dd>

<dt> server </dt><dd>
  Specify a server to use with Rack (e.g. thin, mongrel). If nil is provided Rack::Server is used.<br/><br/>

  <b>default:</b> <code>nil</code>

  <ul>
    <li>CLI: --server SERVER</li>
    <li>ENV: SERVER=[SERVER]</li>
  </ul>
</dd>

<dt> server_port </dt><dd>
  Specify a port to run on a specific port, otherwise Teaspoon will use a random available port.<br/><br/>

  <b>default:</b> <code>nil</code>

  <ul>
    <li>CLI: --server-port PORT</li>
    <li>ENV: SERVER_PORT=[PORT]</li>
  </ul>
</dd>

<dt> server_timeout </dt><dd>
  Timeout for starting the server in seconds. If your server is slow to start you may have to bump this, or you may want to lower this if you know it shouldn't take long to start.<br/><br/>

  <b>default:</b> <code>20</code>

  <ul>
    <li>CLI: --server-timeout SECONDS</li>
    <li>ENV: SERVER_TIMEOUT=[SECONDS]</li>
  </ul>
</dd>

<dt> fail_fast </dt><dd>
  Force Teaspoon to fail immediately after a failing suite. Can be useful to make Teaspoon fail early if you have several suites, but in environments like CI this may not be desirable.<br/><br/>

  <b>default:</b> <code>true</code>

  <ul>
    <li>CLI: -F, --[no-]fail-fast</li>
    <li>ENV: FAIL_FAST=[true/false]</li>
  </ul>
</dd>

<dt> formatters </dt><dd>
  Specify the formatters to use when outputting the results.<br/>
  <b>Note:</b> Output files can be specified by using <code>"junit>/path/to/output.xml"</code>.<br/><br/>

  <b>available:</b> dot, documentation, clean, json, junit, pride, snowday, swayze_or_oprah, tap, tap_y, teamcity<br/>
  <b>default:</b> <code>"dot"</code>

  <ul>
    <li>CLI: -f, --format FORMATTERS</li>
    <li>ENV: FORMATTERS=[FORMATTERS]</li>
  </ul>
</dd>

<dt> color </dt><dd>
  Specify if you want color output from the formatters.<br/><br/>

  <b>default:</b> <code>true</code>

  <ul>
    <li>CLI: -c, --[no-]color</li>
    <li>ENV: COLOR=[true/false]</li>
  </ul>
</dd>

<dt> suppress_log </dt><dd>
  Teaspoon pipes all console[log/debug/error] to $stdout. This is useful to catch places where you've forgotten to remove them, but in verbose applications this may not be desirable.<br/><br/>

  <b>default:</b> <code>false</code>

  <ul>
    <li>CLI: -q, --[no-]suppress-log</li>
    <li>ENV: SUPPRESS_LOG=[true/false]</li>
  </ul>
</dd>

<dt> use_coverage </dt><dd>
  Specify that you always want a coverage configuration to be used.<br/><br/>

  <b>default:</b> <code>nil</code>

  <ul>
    <li>CLI: -C, --coverage=CONFIG_NAME</li>
    <li>ENV: USE_COVERAGE=[CONFIG_NAME]</li>
  </ul>
</dd>

</dl>

### Coverage Configuration Directives

<dl>

<dt> reports </dt><dd>
  Which coverage reports Instanbul should generate. Correlates directly to what Istanbul supports.<br/><br/>

  <b>available:</b> text-summary, text, html, lcov, lcovonly, cobertura, teamcity<br/>
  <b>default:</b> <code>["text-summary", "html"]</code>
</dd>

<dl>

<dt> output_dir </dt><dd>
  The path that the coverage should be written to - when there's an artifact to write to disk.<br/>
  <b>Note:</b> Relative to <code>config.root</code>.<br/><br/>

  <b>default:</b> <code>"coverage"</code>
</dd>

<dl>

<dt> statements </dt><dd>
  Specify a statement threshold. If this coverage threshold isn't met the test run will fail. (0-100) or nil.<br/><br/>

  <b>default:</b> <code>nil</code>
</dd>

<dl>

<dt> functions </dt><dd>
  Specify a function threshold. If this coverage threshold isn't met the test run will fail. (0-100) or nil.<br/><br/>

  <b>default:</b> <code>nil</code>
</dd>

<dl>

<dt> branches </dt><dd>
  Specify a branch threshold. If this coverage threshold isn't met the test run will fail. (0-100) or nil.<br/><br/>

  <b>default:</b> <code>nil</code>
</dd>

<dt> lines </dt><dd>
  Specify a line threshold. If this coverage threshold isn't met the test run will fail. (0-100) or nil.<br/><br/>

  <b>default:</b> <code>nil</code>
</dd>

</dl>

## Test Frameworks

[Jasmine](http://pivotal.github.com/jasmine) is used by default unless you specify otherwise. We've been using Jasmine for a long time, and have been pretty happy with it. It lacks a few important things that could be in a test framework, so we've done a little bit of work to make that nicer. Like adding pending spec support.

[Mocha](http://visionmedia.github.com/mocha) came up while we were working on Teaspoon -- we read up about it and thought it was a pretty awesome library with some really great approaches to some of the things that some of us browser types should consider more often, so we included it and added support for it. We encourage you to give it a try. Read more about [Using Mocha](https://github.com/modeset/teaspoon/wiki/Using-Mocha) with Teaspoon.

[QUnit](http://qunitjs.com) We're not sure about how many people use QUnit, but we like jQuery, so we added it. Read more about [Using QUnit](https://github.com/modeset/teaspoon/wiki/Using-QUnit) with Teaspoon.

[Angular](http://angularjs.org/) This is an experimental addition, and feedback is needed. Read more about [Using Angular](https://github.com/modeset/teaspoon/wiki/Using-Angular) with Teaspoon.


## Support Libraries

We know that testing usually requires more than just the test framework, so we've included some of the libraries that we use on a regular basis.

- [Sinon.JS](http://sinonjs.org) (1.8.2) Standalone test spies, stubs and mocks for JavaScript. No dependencies, works with any unit testing framework. BSD Licence.
- [ChaiJS](http://chaijs.com/) (1.8.1) BDD / TDD assertion library for node and the browser that can be delightfully paired with any javascript testing framework. MIT License.
- [Sinon-Chai](https://github.com/domenic/sinon-chai) (1.0.0) Extends Chai with assertions for the Sinon.JS mocking framework. MIT-ish License.
- [expect.js](https://github.com/LearnBoost/expect.js) (0.1.2) Minimalistic BDD assertion toolkit based on should.js. MIT License.
- [jasmine-jquery-1.7.0.js](https://github.com/velesin/jasmine-jquery) (1.7.0) For Jasmine v1, A set of custom matchers for jQuery, and an API for handling HTML fixtures in your specs. MIT License.
- [jasmine-jquery-2.0.0.js](https://github.com/velesin/jasmine-jquery) (2.0.0) For Jasmine v2, A set of custom matchers for jQuery, and an API for handling HTML fixtures in your specs. MIT License.

You can require these files in your spec helper by using:

```javascript
//= require support/sinon
//= require support/chai
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

All licenses for the [bundled Javascript libraries](https://github.com/modeset/teaspoon/tree/master/vendor/assets/javascripts) are included (MIT/BSD).


## Make Code Not War
![crest](https://secure.gravatar.com/avatar/aa8ea677b07f626479fd280049b0e19f?s=75)

