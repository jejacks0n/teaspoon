Teabag
======
[![Build Status](https://travis-ci.org/modeset/teabag.png)](https://travis-ci.org/modeset/teabag)

Teabag is a Javascript test runner built on top of Rails. It can run tests in the browser, or headlessly using PhantomJS (default) or Selenium WebDriver.

Ok, another test runner, right? Really? Yeah, that's a tough one, but we're pretty confident Teabag is the nicest one you'll find at the moment. And if you disagree, you can swing by our offices in Denver and we'll buy you a beer if you're so inclined.  And we'll probably fix whatever it is that you didn't like.

The intention is to be the simplest but most complete Javascript testing solution for Rails, taking full advantage of the asset pipeline. It ships with support for Jasmine, Mocha and QUnit, and has custom reporters for each.

We've just released Teabag, and we expect to be working on it for a while to get a glossy shine to everything, so check it out and let us know what you think. Feedback, ideas and pull requests would be awesome.

## Screenshots
### Running in the console
![Console Reporter](https://raw.github.com/modeset/teabag/master/screenshots/console-reporter.png)
### Running in the console using [Tapout](https://github.com/rubyworks/tapout)
![Console Reporter Tapout](https://raw.github.com/modeset/teabag/master/screenshots/console-reporter-tapout.png)
### Running in the browser
![Browser Reporter](https://raw.github.com/modeset/teabag/master/screenshots/html-reporter.png)


## Table of Contents

1. [Installation](#installation)
2. [Quickstart](#quickstart)
3. [Usage](#usage)
4. [Writing Specs](#writing-specs)
5. [Suites](#suites)
6. [Configuration](#configuration)
7. [Test Frameworks](#test-frameworks)
8. [Support Libraries](#support-libraries)
9. [CI Support](#ci-support)
10. [Roadmap](#roadmap)

## Installation

Add it to your Gemfile. In almost all cases you'll want to restrict it to the `:asset`, or `:development, :test` groups.

```ruby
group :assets do
  gem "teabag"
end
```

Optionally run the install generator to get the initializer and a basic spec helper if you want them.

```
rails generate teabag:install
```

## Quick Start

1. Create a new Rails app
2. Install Teabag and bootstrap it with the generator (`rails g teabag:install`)
3. Write your first spec (explained in a sec)
4. Run the test suite
5. red. green. refactor.

### Writing your first spec

The install generator will create a `spec/javascripts` directory for you. Teabag will automatically pick up any specs written in that folder named `[classname]_spec.(js|coffee|js.coffee)`.

Let's write a basic class and spec in CoffeeScript using Jasmine (though you could just as easily use vanilla Javascript). Create `spec/javascripts/calculator_spec.coffee` and put this in it:

```coffeescript
#= require calculator

describe 'Calculator', ->

  it 'should add two digits', ->
    calc = new Calculator()
    expect( calc.add(2,2) ).toBe(4)
```

Create `app/assets/javascripts/calculator.coffee` and put this in it:

```coffeescript
class @Calculator
```

Run `rake teabag` - you should see your first failing spec.

```
Failures:

  1) Calculator should add two numbers.
     Failure/Error: TypeError: 'undefined' is not a function
```

Now we just need make the test pass. Let's implement the `add` method on Calculator.

```coffeescript
  add: (a, b) ->
    a + b
```

Run `rake teabag` again - that spec should now be passing!

If you'd prefer, you can also run your tests in the browser. Fire up your Rails server and visit [localhost:3000/teabag](http://localhost:3000/teabag) to run the specs in whichever browser you want.


## Usage

Teabag uses the Rails asset pipeline to serve files which means you're free to use things like CoffeeScript. This simplifies the fixtures as well and lets you do some pretty awesome things like use builder, hamlc, rabl, etc. to generate your views.

If you want a more visual experience you can browse to the specs in the browser, or you can use the rake task to run them headless on the command line with PhantomJS. Works great with CI, too!

### Browser

```
http://localhost:3000/teabag
```

To run a specific suite use:

```
http://localhost:3000/teabag/my_fantastic_suite
```

### Console

```
rake teabag
```

Specify the suite with the rake task by using:

```
rake teabag suite=my_fantastic_suite
```

When a failure is encountered, a URL will be generated so you can pop open a browser and load a focused run to examine that specific failure.

You can override a few configurations by using environment variables. `FAILS_FALSE=[true/false]`, `SUPPRESS_LOGS=[false/true]` and `FORMATTERS=tap_y`. You can read more about these configuration directives below.

Teabag has support for [tapout](https://github.com/rubyworks/tapout). You can use the tap_y formatter and pipe the results to tapout to use any of the reporters that tapout provides.

```
rake teabag SUPPRESS_LOG=true FORMATTERS=tap_y | tapout progress
```

**Note:** By default the rake task runs within the development environment, but you can specify the environment using`RAILS_ENV=test rake teabag`. This is an asset compilation optimization, and to keep consistent with what you might see in the browser (since that's likely running in development).

**Note:** We usually like to include our Javascript specs into the default rake task, like so:

```ruby
task :default => [:spec, :teabag, :cucumber]
```


## Writing Specs

Depending on what framework you use this can be slightly different. There's an expectation that you have a certain level of familiarity with the test framework that you're using. Right now we support [Jasmine](http://pivotal.github.com/jasmine), [Mocha](http://visionmedia.github.com/mocha) and [QUnit](http://qunitjs.com).

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

Check out an example of a [Mocha Spec](https://github.com/modeset/teabag/wiki/Using-Mocha) and a [QUnit Test](https://github.com/modeset/teabag/wiki/Using-QUnit).

### Pending Specs

We've normalized declaring that a spec is pending between the two libraries. Since Jasmine lacks the concept we've added it in, and since Mocha has several ways to accomplish it we thought it would be worth mentioning what we consider the standard between the two to be.

To mark a spec as pending you can either not provide a function as the second argument to `it`, or you can use `xit` and `xdescribe`.  Mocha provides some additional ways to accomplish this, but to keep it consistent we've normalized on what they both support.

```coffeescript
describe "My great feature", ->

  it "hasn't been tested yet"

  xit "has a test I can't figure out" ->
    expect("complexity").to.be("easily testable")

  xdescribe "A whole section that I've not gotten to", ->

    it "hasn't been tested yet", ->
      expect(true).to.be(false)
```

If you're using one library and you want to take advantage of the things that that library provides you're completely free to do so, and this is provided as a suggestion. The Teabag reporters understand the techniques above and have specs for them. QUnit doesn't support specifying a test as pending.

### Fixtures

Teabag fixtures are using jasmine-jquery for now.

If jasmine-jquery isn't your thing, you can also load your fixtures manually into the "#teabag-fixtures" element.

The fixture path is configurable, and the views will be rendered by a controller.  This allows you to use things like rabl if you're building JSON, or haml if you're building markup.

To load fixtures in your specs you'll need to include jasmine-jquery -- and then use the `loadFixtures` method.

```coffeescript
#= require jquery
#= require jasmine-jquery
describe "fixtures", ->

  it "loads fixtures", ->
    loadFixtures("fixture.html")
    expect($("#fixture_view")).toExist()
```

### Deferring Execution

Teabag has the concept of deferring execution in the cases when you're using AMD or other asynchronous libraries. This is especially useful if you're using [CommonJS](http://www.commonjs.org/) or [RequireJS](http://requirejs.org/), etc.

You can tell Teabag to defer and then execute the runner later -- after loading asychronously.

```coffeescript
Teabag.defer = true
setTimeout(Teabag.execute, 1000) # defers execution for 1 second
```


## Suites

Teabag uses the concept of suites to group your tests at a high level. These suites are run in isolation from one another, and can have different configurations.

You can define suites in the configuration, and for brevity `config` is the argument passed to the `Teabag.setup` block.

When creating a suite definition you simply pass it a name and a block. The following example defines a suite named "my_suite". You can focus to just this suite by browsing to `/teabag/my_suite` or running the rake task with `suite=my_suite`.

```ruby
config.suite :my_suite do |suite|
  suite.helper = "my_spec_helper.js"
end
```

There's always a "default" suite defined, and you can modify this suite if you don't specify a name, or use `:default`. In this example we're just adjusting the default suite configuration.

```ruby
config.suite do |suite|
  suite.helper = "other_spec_helper.js"
end
```

It's worth noting that suites don't inherit from the default suite values, but instead always fall back to the defaults outlined below.

### Manifest Style

Teabag is happy to look for files for you, but you can disable this feature and maintain a manifest yourself.  Since each suite can utilize a different spec helper, you can use these to create your own manifest of specs using the `= require` directive.

Tell the suite that you don't want it to match any files, and then require files in your spec helper.

```ruby
config.suite do |suite|
  suite.matcher = nil
  suite.helper = "my_spec_manifest"
end
```

### Suite Configuration Directives

#### `matcher`

You can specify a file matcher for your specs, and the matching files will be automatically loaded when the suite is run. It's important that these files are serve-able from sprockets (aka the asset pipeline), and you'll receive an exception if they aren't.

**Note:** Set this to `nil` if you want to use your helper as a manifest.

**default:** `"{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"`


#### `helper`

Each suite can load a different spec helper, which can in turn require additional files. This file is loaded before your specs are loaded -- so you can use this as a manifest if you set the matcher to nil.

**default:** `"spec_helper"`

#### `javascripts`

These are the core Teabag javascripts. Spec files should not go here -- but if you want to add additional support for jasmine matchers, switch to mocha, include expectation libraries etc., this is a good place to do that.

Available frameworks: teabag-jasmine, teabag-mocha, teabag-qunit

**Note:** To use the CoffeeScript source files use `"teabag/jasmine"` etc.

**Note:** It's strongly encouraged to include only the base files in the `javascripts` directive. You can require other support libraries in your spec helper, which makes them easier to change (you don't have to restart the server.)

**default:** `["teabag-jasmine"]`

#### `stylesheets`

If you want to change how Teabag looks, or include your own stylesheets you can do that here. The default is the stylesheet for the HTML reporter.

**default:** `["teabag"]`


## Configuration

The best way to read about the configuration options is to generate the initializer, but we've included the info here too.

**Note:** `Teabag.setup` may not be available in all environments, so keep that in mind. The generator provides a check wrapped around Teabag.setup.

#### `mount_at`

This determines where the Teabag spec path will be mounted. Changing this to "/jasmine" would allow you to browse to `http://localhost:3000/jasmine` to run your specs.

**default:** `"/teabag"`

#### `root`

The root path defaults to Rails.root if left nil, but if you're testing an engine using a dummy application it's useful to be able to set this to your engines root.. E.g. `Teabag::Engine.root`

**default:** `nil`

#### `asset_paths`

These paths are appended to the rails assets paths (relative to config.root), and by default is an array that you can replace or add to.

**default:** `["spec/javascripts", "spec/javascripts/stylesheets", "test/javascripts", "test/javascripts/stylesheets"]`

#### `fixture_path`

Fixtures are different than the specs, in that Rails is rendering them directly through a controller. This means you can use haml, erb builder, rabl, etc. to render content in the views available in this path.

**default:** `"spec/javascripts/fixtures"`

#### `server_timeout`

Timeout for starting the server in seconds. If your server is slow to start you may have to bump the timeout, or you may want to lower this if you know it shouldn't take long to start.

**default:** `20`

#### `driver`

Allows you to specify which driver you want to run your specs with -- Supports [PhantomJS](http://phantomjs.org/) and [Selenium Webdriver](http://seleniumhq.org/docs/03_webdriver.jsp). For more information about using Selenium WebDriver check this [wiki article](https://github.com/modeset/teabag/wiki/Using-Selenium-WebDriver).

Supported drivers: phantomjs, selenium

**Note:** Override this directive by running `rake teabag DRIVER=selenium`.

**default:** `"phantomjs"`

#### `formatters`

When running Teabag from the command line you can specify the formatters that it will use when displaying the results. Some formatters can be used together, and some are meant to be used by themselves. Play around, and see what you like.

Supported formatters: dot, tap_y, swayze_or_oprah

**Note:** Override this directive by running `rake teabag FORMATTERS=dot,other_formatter`.

**default:** `"dot"`

#### `fail_fast`

When you're running several suites it can be useful to make Teabag fail directly after any suite fails (not continuing on to the next suite), but in environments like CI this isn't as desirable. You can also configure this using the `FAIL_FAST` environment variable.

**Note:** override this directive by running `rake teabag FAIL_FAST=false`

**default:** `true`

#### `suppress_log`

When you run Teabag from the console, it will pipe all console.log/debug/etc. calls to the console. This is useful to catch places where you've forgotten to remove console.log calls, but in verbose applications that use logging heavily this may not be desirable.

**Note:** override this directive by running `rake teabag SUPPRESS_LOG=true`

**default:** `false`


## Test Frameworks

[Jasmine](http://pivotal.github.com/jasmine) is used by default unless you specify otherwise. We've been using Jasmine for a long time, and have been pretty happy with it. It lacks a few important things that could be in a test framework, so we've done a little bit of work to make that nicer. Like adding pending spec support.

[Mocha](http://visionmedia.github.com/mocha) came up while we were working on Teabag -- we read up about it and thought it was a pretty awesome library with some really great approaches to some of the things that some of us browser types should consider more often, so we included it and added support for it. We encourage you to give it a try. Read more about [Using Mocha|Using Mocha] with Teabag.

[QUnit](http://qunitjs.com) We're not sure about how many people use QUnit, but we like jQuery, and it wasn't that hard to add support for it, so we did. Show us some love if you're using it. Read more about [Using QUnit|Using QUnit] with Teabag.


## Support Libraries

Because we know that testing usually requires more than just the test framework we've included some of the great libraries that we use on a regular basis.

- [jasmine-jquery.js](https://github.com/velesin/jasmine-jquery) jQuery matchers and fixture support (Jasmine).
- [Sinon.JS](https://github.com/cjohansen/Sinon.JS) Great for stubbing / spying, and mocking Ajax (Mocha/Jasmine).
- [expect.js](https://github.com/LearnBoost/expect.js) Minimalistic BDD assertion toolkit (Mocha).

You can require these files in your spec helper using:

```javascript
//=require jasmine-jquery
//=require sinon
//=require expect
```


## CI Support

There's a few things that we're doing to make Teabag nicer on CI. We're in the process of integrating a jUnit style XML reporter.

More on this shortly....


## Roadmap

So, there's lots of directions we can take the Teabag project, but we'll give it some time to see what people are looking for.

Check the [issues](https://github.com/modeset/teabag/issues) to see / discuss features that we're considering or are working on.


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)

All licenses for the [bundled Javascript libraries](https://github.com/modeset/teabag/tree/master/vendor/assets/javascripts) are included (all MIT).
