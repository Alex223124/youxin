Youxin::Application.routes.draw do
  resources :receipts do
    post 'favorite' =>  'receipts#favorite', on: :member
    delete 'favorite' => 'receipts#unfavorite', on: :member
  end
  root to: 'receipts#index'
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
  resources :posts, only: [] do
    member do
      get 'unread_receipts' => 'posts#unread_receipts'
      get 'comments' => 'posts#comments'
    end
    resources :attachments, only: [:index]
  end

  get '/uploads/avatar/*path' => 'gridfs#serve'

  require 'api'
  mount Youxin::API => '/'

end
