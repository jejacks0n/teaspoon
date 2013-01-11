Teabag
======
[![Build Status](https://travis-ci.org/modeset/teabag.png)](https://travis-ci.org/modeset/teabag)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/modeset/teabag)

Teabag is a Javascript test runner built on top of Rails. It can run tests in the browser, or headlessly using PhantomJS or with Selenium WebDriver.

It's objective is to be the simplest, while also being the most complete Javascript testing solution for Rails. It takes full advantage of the asset pipeline and ships with support for Jasmine, Mocha and QUnit.

Ok, another Javascript test runner, right? Really? Yeah, that's tough, but we're pretty confident Teabag is one of the nicest you'll find at the moment. And if you disagree, you can swing by our offices in Denver and we'll buy you a beer if you're so inclined -- and probably fix whatever it is that you didn't like.

Feedback, ideas and pull requests are always welcome, or you can hit us up on Twitter [@modeset_](https://twitter.com/modeset_).


## Screenshots

### Running in the console
![Console Reporter](https://raw.github.com/modeset/teabag/master/screenshots/console-reporter.png)

### Running in the console using [Tapout](https://github.com/rubyworks/tapout)
![Console Reporter Tapout](https://raw.github.com/modeset/teabag/master/screenshots/console-reporter-tapout.png)

### Running in the browser
![Browser Reporter](https://raw.github.com/modeset/teabag/master/screenshots/html-reporter.jpg)


## Table of Contents

1. [Installation](#installation)
2. [Usage](#usage)
3. [Writing Specs](#writing-specs)
4. [Fixtures](#fixtures)
5. [Suites](#suites)
6. [Configuration](#configuration)
7. [Test Frameworks](#test-frameworks)
8. [Support Libraries](#support-libraries)
9. [CI Support](#ci-support)

## Installation

Add it to your Gemfile. In most cases you'll want to restrict it to the `:asset`, or `:development, :test` groups.

```ruby
group :assets do
  gem "teabag"
end
```

Optionally run the install generator to get the initializer and a basic spec helper.

```
rails generate teabag:install
```

You can tell the generator which framework you want to use, if you want coffeescript spec helper files, and if you want the env file created (used by the command line interface).

```
rails generate teabag:install --framework=mocha --coffee
```


## Usage

Teabag uses the Rails asset pipeline to serve files. This allows you to use `= require` in your test files, and allows you use things like HAML or RABL/JBuilder within your fixtures.  You can run Teabag in three ways -- in the browser, via the rake task, and using the command line interface.

Here's a great [Quick Start Walkthrough](https://github.com/modeset/teabag/wiki/Quick-Start-Walkthrough) for writing and running your first tests.

### Browser

```
http://localhost:3000/teabag
```

### Rake

```
rake teabag
```

Specify the suite by using:

```
rake teabag suite=my_fantastic_suite
```

### CLI

The command line interface requires a teabag_env.rb file that you can get by running the generator. This file is used to load the Rails environment so Teabag can run within the context of Rails.

```
bundle exec teabag
```

Specify the suite by using:

```
bundle exec teabag --suite=my_fantastic_suite
```

Get full command line help:

```
bundle exec teabag --help
```

Teabag also has support for [tapout](https://github.com/rubyworks/tapout). Use the tap_y formatter and pipe the results to tapout to use any of the reporters that tapout provides.

```
bundle exec teabag -q --format=tap_y | tapout progress
```

**Note:** By default the rake task and command line interface run within the development environment, but you can specify the environment using `RAILS_ENV=test rake teabag`. This is to stay consistent with what you might see in the browser (since that's likely running in development).


## Writing Specs

Depending on what framework you use this can be slightly different. There's an expectation that you have a certain level of familiarity with the test framework that you're using. Right now Teabag supports [Jasmine](http://pivotal.github.com/jasmine), [Mocha](http://visionmedia.github.com/mocha) and [QUnit](http://qunitjs.com).

Since we have the asset pipeline at our fingertips you can feel free to use the `= require` directive throughout your specs and spec helpers.

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

Check out examples of a [Mocha Spec](https://github.com/modeset/teabag/wiki/Using-Mocha) and a [QUnit Test](https://github.com/modeset/teabag/wiki/Using-QUnit).

### Pending Specs

We've normalized declaring that a spec is pending between Mocha and Jasmine. Since Jasmine lacks the concept we've added it in, and since Mocha has several ways to accomplish it we thought it would be worth mentioning what we consider the standard between the two to be. QUnit doesn't support specifying a test as pending.

To mark a spec as pending you can either not provide a function as the second argument to `it`, or you can use `xit` and `xdescribe`. Mocha provides some additional ways to accomplish this, but to keep it consistent we've normalized on what they both support.

```coffeescript
describe "My great feature", ->

  it "hasn't been tested yet"

  xit "has a test I can't figure out" ->
    expect("complexity").to.be("easily testable")

  xdescribe "A whole section that I've not gotten to", ->

    it "hasn't been tested yet", ->
      expect(true).to.be(false)
```

If you're using a specific framework and you want to take advantage of the things that framework provides you're free to do so. This is provided as the standard as the Teabag reporters understand the techniques above and have specs for them.

### Deferring Execution

Teabag allows deferring execution in the cases when you're using AMD or other asynchronous libraries. This is especially useful if you're using [CommonJS](http://www.commonjs.org/) or [RequireJS](http://requirejs.org/), etc.  You can tell Teabag to defer and then execute the runner yourself later -- after loading asychronously.

```javascript
Teabag.defer = true
setTimeout(Teabag.execute, 1000) // defers execution for 1 second
```


## Fixtures

You're free to use your own fixture library (like jasmine-jquery, which we've included as a support library), but Teabag ships with a fixture library that works with Jasmine, Mocha, and QUnit with a minimum of effort and a nice consistent API.

The fixture path is configurable within Teabag, and the views will be rendered by a standard controller.  This allows you to use things like RABL/JBuilder if you're building JSON, or HAML if you're building markup.  The element that Teabag creates is "#teabag-fixtures", in case you need to access it directly -- or you can access it via `fixture.el` after loading fixtures.

### Loading Files

Loading fixtures allows you to specify any number of files to load, and if they should be appended to the fixture element, or replace what's currently there.

`fixture.load(url[, url, ...], append = false)` or `fixture(url[, url, ...], append = false)`

### Setting Manually

If you don't want to load files directly from the server you can provide strings instead of files, otherwise behaves like load.

`fixture.set(html[, html, ...], append = false)`

### Cleaning Up

You shouldn't have to cleanup (we do that for you based on your test framework), but if you need it.

`fixture.cleanup()`

### Preloading Files

Some test cases require stubbing Ajax requests, and in those cases you may want to preload the fixture files -- which caches them for later.  You can preload fixtures in your spec helper, or before you start mocking Ajax methods.

`fixture.preload(url[, url, ...])`

### Example Usage

```coffeescript
fixture.preload("fixture.html", "fixture.json") # make the actual requests for the files
describe "Using fixtures", ->

  fixture.set("<h2>Another Title</h2>") # create some markup manually (will be in a beforeEach)

  beforeEach ->
    @fixtures = fixture.load("fixture.html", "fixture.json", true) # append these fixtures which were already cached

  it "loads fixtures", ->
    expect($("h1", fixture.el).text()).toBe("Title") # using fixture.el as a jquery scope
    expect($("h2", fixture.el).text()).toBe("Another Title")
    expect(@fixtures[0]).toBe(fixture.el) # the element is available as a return value and through fixture.el
    expect(@fixtures[1]).toEqual(fixture.json[0]) # the json for json fixtures is returned, and available in fixture.json
```

Check out an example of using fixtures with [Mocha](https://github.com/modeset/teabag/wiki/Using-Mocha) and [QUnit](https://github.com/modeset/teabag/wiki/Using-QUnit).


## Suites

Teabag uses the concept of suites to group your tests at a high level. These suites are run in isolation from one another, and can have different configurations. You can define suites in the configuration, and for brevity `config` is the argument passed to the `Teabag.setup` block.

When creating a suite, provide a name (optional) and a block. The following example defines a suite named "my_suite". You can focus to just this suite by browsing to `/teabag/my_suite` or running the rake task with `suite=my_suite`.

```ruby
config.suite :my_suite do |suite|
  suite.helper = "my_spec_helper.js"
end
```

There's always a "default" suite defined, and to modify this suite just don't specify a name, or use `:default`. In this example we're setting the default suite configuration.

```ruby
config.suite do |suite|
  suite.helper = "other_spec_helper.js"
end
```

**Note:** Suites don't inherit from the default suite, but instead always fall back to the defaults outlined below.

### Manifest Style

Teabag is happy to look for files for you, but you can disable this feature and maintain a manifest yourself.  Each suite can utilize a different spec helper and you can use these to create your own manifest using the `= require` directive. This limits your abilities to run specific files from the command line interface, but it's available if you want to use it.

Tell the suite that you don't want it to match any files, and then require files in your spec helper.

```ruby
config.suite do |suite|
  suite.matcher = nil
  suite.helper = "spec_manifest"
end
```

### Suite Configuration Directives

#### `matcher`

You can specify a file matcher and all matching files will be loaded when the suite is run. It's important that these files are serve-able from sprockets.

**Note:** Can also be set to `nil`.

**default:** `"{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"`

#### `helper`

Each suite can load a different spec helper, which can in turn require additional files. This file is loaded before your specs are loaded, and can be used as a manifest.

**default:** `"spec_helper"`

#### `javascripts`

These are the core Teabag javascripts. It's strongly encouraged to include only the base files here. You can require other support libraries in your spec helper, which allows you to change them without having to restart the server.

Available: teabag-jasmine, teabag-mocha, teabag-qunit

**Note:** To use the CoffeeScript source files use `"teabag/jasmine"` etc.

**default:** `["teabag-jasmine"]`

#### `stylesheets`

If you want to change how Teabag looks, or include your own stylesheets you can do that here. The default is the stylesheet for the HTML reporter.

**default:** `["teabag"]`


## Configuration

The best way to read about the configuration options is to generate the initializer and env, but we've included the info here as well.

**Note:** `Teabag.setup` may not be available in all environments. The generator provides a check wrapped around Teabag.setup.

#### `mount_at`

This determines where the Teabag routes will be mounted. Changing this to "/jasmine" would allow you to browse to http://localhost:3000/jasmine to run your specs.

**default:** `"/teabag"`

#### `root`

This defaults to Rails.root if left nil. If you're testing an engine using a dummy application it can be useful to set this to your engines root.. E.g. `Teabag::Engine.root`

**default:** `nil`

#### `asset_paths`

These paths are appended to the Rails assets paths (relative to config.root), and by default is an array that you can replace or add to.

**default:** `["spec/javascripts", "spec/javascripts/stylesheets", "test/javascripts", "test/javascripts/stylesheets"]`

#### `fixture_path`

Fixtures are rendered through a standard controller. This means you can use things like HAML or RABL/JBuilder, etc. to generate fixtures within this path.

**default:** `"spec/javascripts/fixtures"`

### Console Runner Specific

These configuration directives are applicable only when running via the rake task or command line interface and should be set within the teabag_env.rb file. You can get this file by running the generator.

#### `driver`

Allows you to specify which driver you want to run your specs with -- Supports [PhantomJS](http://phantomjs.org/) and [Selenium Webdriver](http://seleniumhq.org/docs/03_webdriver.jsp). Check this wiki article for information about [Using Selenium WebDriver](https://github.com/modeset/teabag/wiki/Using-Selenium-WebDriver), and this one about [Using PhantomJS](https://github.com/modeset/teabag/wiki/Using-PhantomJS).

Available: phantomjs, selenium

- CLI: -d, --driver DRIVER
- ENV: DRIVER=selenium

**default:** `"phantomjs"`

#### `server_timeout`

Timeout for starting the server in seconds. If your server is slow to start you may have to bump this, or you may want to lower this if you know it shouldn't take long to start.

- CLI: --server-timeout SECONDS
- ENV: SERVER_TIMEOUT=10

**default:** `20`

#### `fail_fast`

If you have several suites it can be useful to make Teabag fail directly after any suite contains failures, but in environments like CI this may not be desirable.

- CLI: --[no-]fail-fast
- ENV: FAIL_FAST=false

**default:** `true`

#### `formatters`

You can specify the formatters that Teabag will use when outputting the results.

Supported formatters: dot, tap_y, swayze_or_oprah

- CLI: -f, --format FORMATTERS
- ENV: FORMATTERS=dot,swayze_or_oprah

**default:** `"dot"`

#### `suppress_log`

Teabag pipes all console[log/debug/error] calls to STDOUT. This is useful to catch places where you've forgotten to remove them, but in verbose applications this may not be desirable.

- CLI: -q, --[no-]suppress-log
- ENV: SUPPRESS_LOG=true

**default:** `false`

#### `color`

Specify if you want color output by default.

- CLI: --[no-]color
- ENV: COLOR=false

**default:** `true`


## Test Frameworks

[Jasmine](http://pivotal.github.com/jasmine) is used by default unless you specify otherwise. We've been using Jasmine for a long time, and have been pretty happy with it. It lacks a few important things that could be in a test framework, so we've done a little bit of work to make that nicer. Like adding pending spec support.

[Mocha](http://visionmedia.github.com/mocha) came up while we were working on Teabag -- we read up about it and thought it was a pretty awesome library with some really great approaches to some of the things that some of us browser types should consider more often, so we included it and added support for it. We encourage you to give it a try. Read more about [Using Mocha](https://github.com/modeset/teabag/wiki/Using-Mocha) with Teabag.

[QUnit](http://qunitjs.com) We're not sure about how many people use QUnit, but we like jQuery, so we added it. Read more about [Using QUnit](https://github.com/modeset/teabag/wiki/Using-QUnit) with Teabag.


## Support Libraries

We know that testing usually requires more than just the test framework, so we've included some of the libraries that we use on a regular basis.

- [jasmine-jquery.js](https://github.com/velesin/jasmine-jquery) jQuery matchers and fixture support (Jasmine).
- [expect.js](https://github.com/LearnBoost/expect.js) Minimalistic BDD assertion toolkit (Mocha).
- [Sinon.JS](https://github.com/cjohansen/Sinon.JS) Great for stubbing / spying, and mocking Ajax.

You can require these files in your spec helper by using:

```javascript
//=require support/jasmine-jquery
//=require support/sinon
//=require support/expect
```


## CI Support

There's a few things that we're doing to make Teabag nicer on CI. We're in the process of integrating a jUnit style XML reporter.

More on this shortly....


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)

Copyright 2012 [Mode Set](https://github.com/modeset)

All licenses for the [bundled Javascript libraries](https://github.com/modeset/teabag/tree/master/vendor/assets/javascripts) are included (MIT/BSD).


## Make Code Not War
![crest](https://secure.gravatar.com/avatar/aa8ea677b07f626479fd280049b0e19f?s=75)

