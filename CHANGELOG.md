### 1.0.0 (unreleased)

#### Upgrade Steps

- Change your Gemfile to use "teaspoon-framework" instead of "teaspoon".
  eg: If you are using Mocha, this would be "gem 'teaspoon-mocha'"

- Rename teaspoon_env.rb to teaspoon.rb.

- Update your coverage configuration.
  If you use Teaspoon to generate coverage reports with Istanbul, and you use the `suite.no_coverage` to exclude files from coverage, you'll need to migrate that configuration into the `config.coverage` blocks. So if you have:

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


#### Enhancements

* Break frameworks out into individual gems (eg teaspoon-mocha)
* Frameworks (eg mocha, jasmine) can now be registered with core
* Formatters (eg dot, documentation) can now be registered with core
* Drivers (eg phantomjs, selenium) can now be registered with core
* Support for Jasmine 2.0
* Support for Mocha 2.0
* Improved abstractions around how framework events are handled (via responders)
* Can now specify framework version when installing
* Backfill support for old versions of frameworks
* Lots of refactors to clean things up

#### Bug Fixes

* Fix files excluded from coverage for RequireJS (@davestevens)
* Fix double teaspoon hook (#332)


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
