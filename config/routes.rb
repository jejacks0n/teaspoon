Teaspoon::Engine.routes.draw do
  get "/fixtures/*filename", to: "spec#fixtures"
  get "/:suite", to: "spec#runner", defaults: { suite: "default" }
  post "/:suite/hooks(/:group)", to: "spec#hooks", defaults: { suite: "default", group: "default" }
  root to: "spec#suites"
end
