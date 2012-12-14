Teabag
======

Teabag is a Javascript test runner built on top of Rails. It can run tests in the browser, or headlessly using PhantomJS.

Ok, another test runner, right? Really? Yeah, that's a tough one, but we're pretty confident Teabag is the nicest one you'll find at the moment. And if not, you can swing by our offices in Denver and we'll hang out with you and share a beer if you're so inclined.

It's intention is to be the simplest, but most complete Javascript testing solution for Rails utilizing the asset pipeline. It ships with the ability to use Jasmine or Mocha and has custom reporters for both libraries.

Check out the [screenshots](https://github.com/modeset/teabag/tree/master/screenshots).

We've just released Teabag, and we expect to be working on it for a while to get a glossy shine to everything, so check it out, write a few specs, and let us know what you think. Feedback and ideas would be awesome.

## Table of Contents

1. [Installation](#installation)
2. [Quickstart](#quickstart)
3. [Usage](#usage)
4. [Writing Specs](#writing-specs)
5. [Suites](#suites)
6. [Configuration](#configuration)
7. [Jasmine](#jasmine)
8. [Mocha](#mocha)

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

## Quickstart

1. Create A new rails app
2. Install teabag and bootstrap with the generator (as described above)
3. Write your first spec (explained in a sec)
4. Run the test suite
5. red. green. refactor.

### Writing your first spec

The install generator it will bootstrap you with a `spec/javascripts` directory. Teabag will automatically pick up any specs written in that folder that are named `[classname]_spec.js` (or .js.coffee/.coffee).

Here we're going to write the spec in CoffeeScript using Jasmine.

```
mkdir -p spec/javascripts
```

Open a file `spec/javascripts/calculator_spec.coffee` in your favorite editor.

```coffeescript
#= require calculator

describe 'Calculator', ->

  it 'should add two digits', ->
    calc = new Calculator()
    expect( calc.add(2,2) ).toBe(4)
```

Save and close that file and run `rake teabag` from within the rails directory. You should see an error that the `calculator` file can't be found. Great. It doesn't exist yet, so we'll make it by opening a file at `app/assets/javascripts/calculator.coffee` and adding the following code.

```coffeescript
class @Calculator
```

Run `rake teabag` again and you should have your first failing spec.  Now we just need to finish it up and make the test pass by adding the `add` method to Calculator.

```coffeescript
  add: (a, b) ->
    a + b
```

Run `rake teabag` again and you should have your first passing spec!

Start up your rails server and visit [localhost:3000/teabag](http://localhost:3000/teabag) to run the specs in the browser.


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

Additional arguments to the rake command are `fails_fast=[true/false]` and `suppress_logs=[false/true]`. You can read more about these options / configuration directives below.

**Note:** By default the rake task runs within the development environment, but you can specify the environment using`RAILS_ENV=test rake teabag`. This is an asset compilation optimization, and to keep consistent with what you might see in the browser (since that's likely running in development).

**Note:** We like to include our javascript specs into the default rake task, like so:

```ruby
task :default => [:spec, :teabag, :cucumber]
```


## Writing Specs

Depending on what framework you use this can be slightly different. There's an expectation that you have a certain level of familiarity with the test framework that you're using. Right now we support [Jasmine](http://pivotal.github.com/jasmine/) and [Mocha](http://visionmedia.github.com/mocha/).

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

Here's the same test written in CoffeeScript using Mocha + [expect.js](https://github.com/LearnBoost/expect.js) (Teabag ships with expect.js and other support libraries like [jasmine-jquery](https://github.com/velesin/jasmine-jquery).):

```coffeescript
#= require jquery
describe "My great feature", ->

  it "will change the world", ->
    expect(true).to.be(true)
    expect(true).to.not.be(undefined)
```

### Pending Specs

We've normalized declaring that a spec is pending between the two libraries. Since Jasmine lacks the concept we've added it in, and since Mocha has several ways to accomplish it we thought it would be worth mentioning what we consider the standard between the two to be.

To mark a spec as pending you can either not provide a function as the second argument to `it`, or you can use `xit` and `xdescribe`.  Mocha provides some additional ways to accomplish this, but to keep it consistent we've normalized on what they both support easily.

```coffeescript
describe "My great feature", ->

  it "hasn't been tested yet"

  xit "has a test I can't figure out" ->
    expect("complexity").to.be("easily testable")

  xdescribe "A whole section that I've not gotten to", ->

    it "hasn't been tested yet", ->
      expect(true).to.be(false)
```

If you're using one library and you want to take advantage of the things that that library provides you're completely free to do so, and this is provided as a suggestion more than anything. The Teabag reporters understand the techniques above and have specs for them.

### Fixtures

Teabag fixtures are using jasmine-jquery for now, but we'll be providing a more complete solution for loading fixtures at some point in the future.

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

Teabag uses the concept of suites to group your tests at a high level. These suites are run in isolation from one another, and can have entirely different configurations.

When Teabag is run via the rake task, it will stop at any point that a suite fails, which allows you to create a hierarchy of suites -- crafting tiers of pass expectation.  The fail_fast configuration lets you override this behavior -- useful for CI (more on setting these via env in the configuration section).

You can define suites in the configuration, and for brevity `config` is the argument passed to the `Teabag.setup` block.

When creating a suite definition you simply pass it a name, and a configuration block. The following example defines a suite named "my_suite". You can focus to just this suite by browsing to `teabag/my_suite` or running the rake task with `suite=my_suite`.

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

Tell the suite that you don't want it to match any files, and then retuire files in your spec helper.

```ruby
config.suite do |suite|
  suite.matcher = nil
  suite.helper = "my_spec_manifest"
end

```

### Suite Configuration Directives

#### `matcher`

You can specify a file matcher for your specs, and the matching files will be automatically loaded when the suite is run. It's important that these files are serve-able from sprockets (aka the asset pipeline), otherwise you'll receive a warning about it.

**default:** `"{spec/javascripts,app/assets}/**/*_spec.{js,js.coffee,coffee}"`

**Note:** set this to nil if you want to use your spec helper as a manifest.

#### `helper`

Each suite can load a different spec helper, which can in turn require additional files since this file is also served via the asset pipeline. This file is loaded before your specs are loaded -- so could potentially include all of your specs (if you set the matcher to nil).

**default:** `"spec_helper"`

#### `javascripts`

These are the core Teabag javascripts. Spec files should not go here -- but if you want to add additional support for jasmine matchers, switch to mocha, include expectation libraries etc., this is a good place to do that.

To use mocha switch this to: `"teabag-mocha"`

To use the coffeescript source files: `"teabag/jasmine"` or `"teabag/mocha"`

**default:** `["teabag-jasmine"]`

**Note:** It's strongly encouraged to only include the base files in the `javascripts` directive. You can require any other libraries you need in your spec helper, which makes it easier to maintain because you don't have to restart the server.

#### `stylesheets`

If you want to change how Teabag looks, or include your own stylesheets you can do that here. The default is the stylesheet for the HTML reporter.

**default:** `["teabag"]`


## Configuration

The best way to read about the configuration options is to generate the initializer, but we've included the info here too.

**Note:** `Teabag.setup` may not be available in all environments, so keep that in mind. The generator provides a check wrapped around Teabag.setup.

#### `mount_at`

This determines where the Teabag spec path will be mounted. Changing this to `"/jasmine"` would allow you to browse to `http://localhost:3000/jasmine` to run your specs.

**default:** `"/teabag"`

#### `root`

The root path defaults to Rails.root if left nil, but if you're testing an engine using a dummy application it's useful to be able to set this to your engines root.. E.g. `Teabag::Engine.root`

**default:** `nil`

#### `asset_paths`

These paths are appended to the rails assets paths (relative to config.root), and by default is an array that you can replace or add to.

**default:** `["spec/javascripts", "spec/javascripts/stylesheets"]`

#### `fixture_path`

Fixtures are different than the specs, in that Rails is rendering them directly through a controller. This means you can use haml, erb builder, rabl, etc. to render content in the views available in this path.

**default:** `"spec/javascripts/fixtures"`

#### `server_timeout`

Timeout for starting the server in seconds. If your server is slow to start you may have to bump the timeout, or you may want to lower this if you know it shouldn't take long to start.

**default:** `20`

#### `fail_fast`
When you're running several suites it can be useful to make Teabag fail directly after any suite fails (not continuing on to the next suite), but in environments like CI this isn't as desirable. You can also configure this using the fail_fast environment variable.

**Note:** override this directive by running `rake teabag fail_fast=false`

**default:** `true`

#### `suppress_log`

When you run Teabag from the console, it will pipe all console.log/debug/etc. calls to the console. This is useful to catch places where you've forgotten to remove console.log calls, but in verbose applications that use logging heavily this may not be desirable.

**Note:** override this directive by running `rake teabag suppress_log=true`

**default:** `false`


## Jasmine

Jasmine is a pretty big aspect of the default setup. We've been using Jasmine for a long time, and have been pretty happy with it.  It lacks a few important things that could be in a test framework, so we've done a little bit of work to make that nicer.  Like adding pending spec support.


## Mocha

Mocha came up while we were working on Teabag -- we read up about it and thought it was a pretty awesome library with some really great approaches to some of the things that some of us browser types should consider more often, so we included it and added support for it. We encourage you to give it a try.

Read [more about Mocha](http://visionmedia.github.com/mocha/).

To use Mocha just change your suite to include the `teabag-mocha` javascript.

```ruby
config.suite do |suite|
  suite.javascripts = ["teabag-mocha"]
end
```


## CI Support

There's a few things that we're doing to make Teabag nicer on CI. We'll be integrating a jUnit style XML reporter.

More on this shortly....


## Road Map

So, there's lots of directions we can take the Teabag project, but we'll give it some time to see what people are looking for.  Here's a short list of things that will probably happen.

- A Command Line Interface to allow running as `teabag spec/javascripts/calculator_spec.coffee` with proper arguments that will let you override configuration.

- Add support for running Teabag using selenium.

- Improve the user interface in the html reporter by adding a select for switching suites.


## Support Libraries

Because we know that testing usually requires more than just the test framework we've included some of the great libraries that we use on a consistent basis.

- [jasmine-jquery.js](https://github.com/velesin/jasmine-jquery) Great jQuery matchers and fixture support (Jasmine).
- [Sinon.JS](https://github.com/cjohansen/Sinon.JS) Great for stubbing Ajax (Mocha/Jasmine).
- [expect.js](https://github.com/LearnBoost/expect.js) Minimalistic BDD assertion toolkit (Mocha).


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
