Rails.application.routes.draw do
  resources :digit_recognizers

  root to: 'digit_recognizers#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
