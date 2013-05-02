Youxin::Application.routes.draw do
  get "organizations/new"

  get "organizations/index"

  root to: 'admin/users#index'
  devise_for :users

  namespace :admin do
    resources :users
    post 'users/excel_importor' => 'users#excel_importor'
    resources :organizations
  end

  get '/uploads/avatar/*path' => 'gridfs#serve'
end
