Youxin::Application.routes.draw do
  root to: 'admin/users#index'
  devise_for :users
  devise_for :users, controllers: { registrations: 'registrations' }

  namespace :admin do
    resources :users
  end
end
