Teabag::Engine.routes.draw do
  match "/fixtures/*filename", to: "spec#fixtures"
  match "/(:suite)", :to => "spec#index", defaults: { suite: nil }
end

Rails.application.routes.draw do
  mount Teabag::Engine => Teabag.configuration.mount_at
end
