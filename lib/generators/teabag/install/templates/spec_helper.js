// This is your spec helper. You can require other javascript files in this one and they'll be loaded into your suite.
//
// Teabag includes some useful javascripts for you, and you can include them here.
// require jasmine-jquery
// require sinon
// require expect
//
// You're also able to include any of the files in support as well.
// require support/your-support-file
//
// Deferring execution
// This is useful if you're using CommonJS or RequireJS or some other asynchronous loading method. To defer test
// execution until everything has been loaded asynchronously you can tell Teabag to defer, which then allows you to call
// Teabag.execute() at a later time. Here's a simple example:
//
// Teabag.defer = true
// setTimeout(function() { Teabag.execute() }, 1000)
//
// Spec files
// By default Teabag will go looking for files that match the _spec.{js,js.coffee,.coffee} naming convention, so just
// start dropping filename_spec.js files into this, or any nested path, and they'll automatically be picked up and
// included in the default suite.  If you're interested in creating custom suites, check out the configuration in
// config/initializers/teabag.rb
//
// For more information:
// http://github.com/modeset/teabag
