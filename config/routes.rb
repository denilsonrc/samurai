Rails.application.routes.draw do
  resources :rooms
  resources :equipment
  root to: 'dashboard#index'
  get 'dashboard/statistic'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
