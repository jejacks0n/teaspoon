Teaspoon::Engine.routes.draw do
  get "/fixtures/*filename", to: "spec#fixtures"
  get "/:suite", to: "spec#runner", defaults: { suite: "default" }
  root to: "spec#suites"
end
