Teabag::Engine.routes.draw do
  match "/fixtures/*filename", to: "spec#fixtures", via: :get
  match "/(:suite)", to: "spec#index", via: :get, defaults: { suite: "default" }
end
