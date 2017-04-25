Rails.application.routes.draw do
  get'it_expense/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :configurations do
    resources :management_overview
    resources :tsm_settings
    resources :rep_settings
    resources :annual_quarter
    resources :sro_responsibility
    resources :sro_failure_code
    resources :sro_report_criteria
  end

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
  root to: "configurations/management_overview#index"
end
