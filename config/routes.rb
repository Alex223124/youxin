Youxin::Application.routes.draw do
  resources :forms, only: [:create] do
    get 'collection' => 'forms#get_collection', on: :member
    get 'collections' => 'forms#collections', on: :member
    post 'collection' => 'forms#create_collection', on: :member
  end
  get 'receipts/read' => 'receipts#read'
  get 'receipts/unread' => 'receipts#unread'
  resources :receipts do
    put 'read' => 'receipts#mark_as_read', on: :member
    post 'favorite' =>  'receipts#favorite', on: :member
    delete 'favorite' => 'receipts#unfavorite', on: :member
  end
  root to: 'receipts#index'
  devise_for :users
  resources :users, only: [:update] do
    get 'authorized_organizations' => 'users#authorized_organizations', on: :collection
    get 'recent_authorized_organizations' => 'users#recent_authorized_organizations', on: :collection
    get 'organizations' => 'users#organizations', on: :member
  end

  resources :organizations, only: [:destroy, :index, :update] do
    get 'members' => 'members#index', on: :member
    post 'members' => 'members#create', on: :member
    put 'members' => 'members#update', on: :member
    get 'authorized_users' => 'organizations#authorized_users', on: :member
    post 'children' => 'organizations#create', on: :member
  end

  resource :user, only: [] do
    put '' => 'user#update'
    get '' => 'user#show'
    get 'organizations' => 'user#organizations'
    get 'created_receipts' => 'user#created_receipts'
    get 'favorited_receipts' => 'user#favorited_receipts'
  end

  namespace :admin do
    resources :users, only: [:new, :create, :index]
    post 'users/excel_importor' => 'users#excel_importor'
    resources :organizations, only: [:new, :create, :destroy, :index] do
      get 'members' => 'members#index', on: :member
      put 'members' => 'members#update', on: :member
      delete 'members' => 'members#destroy', on: :member
    end
  end

  # help
  get 'help/positions' => 'help#positions'

  resources :attachments, only: [:show, :create]
  resources :posts, only: [:create] do
    member do
      get 'unread_receipts' => 'posts#unread_receipts'
      get 'comments' => 'posts#get_comments'
      post 'comments' => 'posts#create_comments'
      get 'forms' => 'posts#forms'
      post 'sms_notifications' => 'posts#sms_notifications'
    end
    resources :attachments, only: [:index]
  end

  get '/uploads/avatar/*path' => 'gridfs#serve'

  require 'api'
  mount Youxin::API => '/'

end
