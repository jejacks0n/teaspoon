Teabag::Engine.routes.draw do
  match "/fixtures/*filename", to: "spec#fixtures"
  match "/(:suite)", :to => "spec#index", defaults: { suite: nil }
end
