Youxin::Application.routes.draw do
  root to: 'admin/users#index'
  devise_for :users

  namespace :admin do
    resources :users, only: [:new, :create, :index]
    post 'users/excel_importor' => 'users#excel_importor'
    resources :organizations, only: [:new, :create, :destroy, :index] do
      get 'members' => 'members#index', on: :member
      put 'members' => 'members#update', on: :member
      delete 'members' => 'members#destroy', on: :member
    end
  end

  resources :attachments, only: [:show]

  get '/uploads/avatar/*path' => 'gridfs#serve'
  get '/uploads/header/*path' => 'gridfs#serve'

  require 'api'
  mount Youxin::API => '/'

end
