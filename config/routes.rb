Teabag::Engine.routes.draw do
  get "/fixtures/*filename", to: "spec#fixtures"
  get "/suites", to: "spec#suites"
  get "/(:suite)", to: "spec#runner", defaults: { suite: "default" }
end
