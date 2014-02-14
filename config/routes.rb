Teaspoon::Engine.routes.draw do

  root  to: "suite#index"

  match "/fixtures/*filename",
        to: "suite#fixtures", via: [:get]

  match "/:suite", as: "suite",
        to: "suite#show", via: [:get],
        defaults: { suite: "default" }

  match "/:suite/:hook", as: "suite_hook",
        to: "suite#hook", via: [:get, :post],
        defaults: { suite: "default", hook: "default" }

end
