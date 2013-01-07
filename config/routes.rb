Teabag::Engine.routes.draw do
  get "/fixtures/*filename", to: "spec#fixtures", via: :get
  get "/(:suite)", to: "spec#index", via: :get, defaults: { suite: "default" }
end
