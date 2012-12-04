# This is your spec helper. You can require other javascript files in this one and they'll be loaded into your test
# environment. Teabag includes some useful javascripts for you, and you can include them here.
#
# require jasmine-jquery
# require sinon
# require expect
#
# You're also able to include any of the files in support as well.
#
# require support/your-support-file
#
# Defering execution
# This is useful if you're using CommonJS or RequireJS. To defer test execution until everything has been loaded
# asynchronously you can tell Teabag to defer, which then allows you to call Teabag.execute() at a later time. Here's a
# simple example:
#
# Teabag.defer = true
# setTimeout((-> Teabag.execute()), 1000)
#

window.passing = true
window.failing = false
