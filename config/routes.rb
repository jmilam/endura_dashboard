Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :sros do
    resources :order_entries
    resources :alls
  end
end
