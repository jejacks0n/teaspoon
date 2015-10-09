### Unreleased

#### Bug Fixes


### 1.1.1

#### Bug Fixes

* Fix teaspoon cli environment checking


### 1.1.0

#### Enhancements

* Support invalid HTML in fixtures (#387)
* Configurable JavaScript extensions via suite.js_extensions (#418)
* Fail build when Phantomjs fails (b34c4)
* Add new versions of test frameworks to the latest minor versions

#### Bug Fixes

* Retain file filter when navigating to specs (#327)
* Provide details when Istanbul fails (#368)
* Fix support for barebones Rails app (#372)
* Fix pending count and nested styles (#373)
* Fix total count in Jasmine 2 (#378)
* Deprecate and fix suite.use_framework= (#394)
* Fix capybara-webkit synchronization (#403)
* Fix reporting in IE8 (97cf6)
* Fix Jasmine's "fit" (f5e2a)


### 1.0.2 (5/5/15)

#### Bug Fixes

* Use a more robust phantomjs polyfill (#360)
* Revive support for 1.9.3 (#361)


### 1.0.1 (5/5/15)

#### Bug Fixes

* Fix constant scoping for Phantomjs (#359)


### 1.0.0 (5/4/15)

#### Upgrade Steps

- **Update your Gemfile**<br>
  Change your Gemfile to use `teaspoon-jasmine` instead of `teaspoon`, if you're using Jasmine. If you're using Mocha, this would be `teaspoon-mocha`. Use `teaspoon-qunit` for QUnit.<br>
  eg: For Jasmine:
  ```ruby
  gem 'teaspoon-jasmine'
  ```
  For Mocha:
  ```ruby
  gem 'teaspoon-mocha'
  ```
  For QUnit:
  ```ruby
  gem 'teaspoon-qunit'
  ```

  If you had Teaspoon locked at a specific version, kill the version. You'll now need to reference the version of the framework, instead of the version of Teaspoon.<br>
  eg: If your Gemfile has `gem 'teaspoon', '0.9.1'` and you're using Mocha, you'll want your Gemfile to reference the latest version of Mocha: `gem 'teaspoon-mocha', '2.2.4'`. The teaspoon-mocha gem contains previous versions of Mocha, so even if you're not using version 2.2.4 of Mocha in your `teaspoon_env.rb`, still reference the latest version in your Gemfile and the older version should still work.

- **Configuration: Update your coverage**<br>
  In `teaspoon_env.rb`, if you use Teaspoon to generate coverage reports with Istanbul, and you use the `suite.no_coverage` to exclude files from coverage, you'll need to migrate that configuration into the `config.coverage` blocks. So if you have:

  ```ruby
  suite.no_coverage += /my_file.js/
  ```

  You should move this into the `coverage` block:

  ```ruby
  config.coverage do |coverage|
    coverage.ignore += /my_file.js/
  end
  ```

  This means that you can no longer exclude things at the suite level. If you had multiple suites with different `no_coverage` configurations, you'll now need to create multiple coverage blocks and specify the coverage you want when using the CLI.
  eg: teaspoon --coverage=[coverage_name]

- **Configuration: Prefer suite.use_framework over suite.javascripts**<br>
  Teaspoon now has better support for framework versions. In `teaspoon_env.rb`, if you are using `suite.javascripts` to include the testing framework, you should use `suite.use_framework` with a version number instead.

  If your `teaspoon_env.rb` has `suite.javascripts` configured:

  ```ruby
  suite.javascripts = ["jasmine/1.3.1", "teaspoon-jasmine", "your-custom-file.js"]
  ```

  This will break since `teaspoon-jasmine` no longer exists. Update this config to exclude any framework or Teaspoon files. Be sure to use `+=` as Teaspoon will be modifying this array to append framework and Teaspoon files.

  ```ruby
  suite.javascripts += ["your-custom-file.js"]
  ```

#### Enhancements

* Break frameworks out into individual gems (eg teaspoon-mocha)
* Frameworks (eg mocha, jasmine) can now be registered with core
* Formatters (eg dot, documentation) can now be registered with core
* Drivers (eg phantomjs, selenium) can now be registered with core
* Support for Jasmine 2.0
* Support for Mocha 2.0
* Improved abstractions around how framework events are handled (via responders)
* Can now specify framework version when installing
* Adds `rake teaspoon:info` to show Teaspoon and framework versions
* Backfill support for old versions of frameworks
* Fail faster when teaspoon_env.rb cannot be found
* Lots of refactors to clean things up

#### Bug Fixes

* Fix files excluded from coverage for RequireJS (@davestevens)
* Fix double teaspoon hook (#332)
* Instrument files when config.expand_assets is false (#357)


### 0.9.1 (3/2/15)

* Fixes an issue where suite view was failing
* CI/Linux stability improvement (alphanumeric ordering of spec files)


### 0.9.0 (2/24/15)

#### Enhancements

* Add `expand_assets` suite configuration to control spec compilation
* Provide QUnit tests with a default `equal` message
* Support cli reusing running Rails server
* Add support for Capybara Webkit
* Better support for RequireJS
* Add RSpec HTML formatter

#### Bug Fixes

* Fix qunit 1.14.0 precompile path

#### Removals

* Direct support for Angular


### 0.8.0 (4/18/14)

Configuration has changed considerably, and deprecation warnings have been provided. In general it's probably best to remove your /initializers/teaspoon.rb and reinstall using the generator. Configuration is now consolidated into spec/teaspoon_env.rb. **This can cause a stack level too deep exception unless the teaspoon_env.rb file properly wraps the loading of rails in a `defined?(Rails)` check.**

#### Upgrade Steps

1. backup your `spec/teaspoon_env.rb` file.
2. run the install generator to get the new `teaspoon_env.rb`.
3. migrate your old settings into the new file, noting the changes that might exist.
4. move all settings that you had in `config/initializers/teaspoon.rb` into `spec/teaspoon_env.rb` and delete the initializer.

#### Coverage reports

Coverage has changed in terms of configuration, to allow for different coverage configurations, and they behave a lot like suite configurations now. You can have any number of coverage configurations and can specify which coverage configuration to use from the command line.

```ruby
config.coverage do |coverage|
   coverage.reports = ["text"]
end
config.coverage :CI do |coverage|
   coverage.reports = ["cobertura", "lcov"]
end
config.use_coverage = :CI
```

#### Frameworks

The configuration around which test framework is used for a suite has been changed and improved. Instead of configuring via the `javascripts` directive we're transitioning to a more complete structure with `use_framework`.

You can specify version of test framework with `use_framework` now, which allows for the gem to be updated, while keeping the impact on your specs minimal.

```ruby
suite.use_framework :mocha, "1.10.0"
```

#### Formatters

Running CI with two formatters is easier, as formatters can be sent to file output instead of just $stdout by using > in the formatter name to be used. Just remember to wrap it in a string when you specify it in the CLI -- or all output will be piped to that file.

```
teaspoon --format="dots,junit>/path/to/junit_output.xml"
config.formatters =  ["dots", "junit>/path/to/junit_output.xml"]
```

#### Drivers

Drivers have a more feature complete configuration strategy. For PhantomJS you can provide a string of flags (eg. --debug=true), and the selenium driver can accept a hash (or json string) to specify something other than firefox for instance.
