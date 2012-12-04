Teabag
======

Teabag is a Javascript test runner built on top of Rails.  It can run headless using PhantomJS or in the browser within
your Rails application.  It's intention is to be the simpliest, but most complete Javascript testing solution for Rails
and the asset pipeline.  It ships with the ability to use Jasmine or Mocha and has custom reporters for both libraries.

## Installation

Add it to your Gemfile.  In most cases you'll want to restrict it to the asset group.

    group :assets do
      gem "teabag"
    end

In addition, to get setup you can install the initializer and get the spec/javascripts paths created for you with a
basic spec_helper.js file.

    rails generate teabag:install


## Usage

There's a lot of use cases, and that's one of the things that Teabag tries to keep managable.  By default it uses
PhantomJS to run your specs headless, and uses Rails to serve the files using the asset pipeline.  But at the same time
you can access the runner in the browser.  This allows you to do some pretty awesome things with fixtures (using erb,
haml, builder, rabl, etc.)

### Console

    rake teabag

### Browser

    http://localhost:3000/teabag


## Configuration

The best way to read about the configuration options is to generate the initializer.  The configuration directives are
outlined in detail there.


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
