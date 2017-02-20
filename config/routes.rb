Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :sros do
    resources :order_entries
    resources :alls
    resources :report_card
  end
  namespace :salesforces do
  	#namespace :reports do
  		resources :sales_calls
      resources :data_export
  	#end
  end
  root to: "sros/alls#index"
end
