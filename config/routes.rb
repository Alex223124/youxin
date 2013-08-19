Youxin::Application.routes.draw do
  root to: 'home#index'
  resources :receipts, only: [:index] do
    member do
      put 'read' => 'receipts#read'
      post 'favorite' =>  'receipts#favorite'
      delete 'favorite' => 'receipts#unfavorite'
    end
  end
  resources :organizations, only: [:index, :update, :destroy] do
    member do
      post 'children' => 'organizations#create_children'
    end
  end
  resources :forms, only: [:create] do
    member do
      get 'download' => 'forms#download'
    end
    resources :collections, only: [:create, :index]
    resource :collection, only: [:show]
  end
# ------------need fix-----------------
  resources :forms, only: [:create] do
    member do
      get 'collection' => 'forms#get_collection'
      get 'collections' => 'forms#collections'
      post 'collection' => 'forms#create_collection'
      get 'download' => 'forms#download'
    end
  end
  get 'receipts/read' => 'receipts#read'
  get 'receipts/unread' => 'receipts#unread'
  devise_for :users
  resources :users, only: [:update] do
    get 'authorized_organizations' => 'users#authorized_organizations', on: :member
    get 'recent_authorized_organizations' => 'users#recent_authorized_organizations', on: :member
    get 'organizations' => 'users#organizations', on: :member
  end

  resources :organizations, only: [:destroy, :index, :update] do
    get 'members' => 'members#index', on: :member
    post 'members' => 'members#create', on: :member
    put 'members' => 'members#update', on: :member
    put 'members/role' => 'members#update_role', on: :member
    get 'authorized_users' => 'organizations#authorized_users', on: :member
    post 'children' => 'organizations#create', on: :member
    post 'members/import' => 'members#import', on: :member
    get 'all_members' => 'organizations#all_members', on: :member
  end

  resource :user, only: [] do
    put '' => 'user#update'
    get '' => 'user#show'
    get 'organizations' => 'user#organizations'
    get 'created_receipts' => 'user#created_receipts'
    get 'favorited_receipts' => 'user#favorited_receipts'
    get 'authorized_organizations' => 'user#authorized_organizations'
    get 'recent_authorized_organizations' => 'user#recent_authorized_organizations'
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
  get 'help/roles' => 'help#roles'

  resources :attachments, only: [:show, :create]
  resources :posts, only: [:create] do
    member do
      get 'unread_receipts' => 'posts#unread_receipts'
      get 'comments' => 'posts#get_comments'
      post 'comments' => 'posts#create_comments'
      get 'forms' => 'posts#forms'
      post 'sms_notifications' => 'posts#sms_notifications'
      get 'sms_scheduler' => 'posts#sms_scheduler'
    end
    resources :attachments, only: [:index]
  end

  get '/uploads/avatar/*path' => 'gridfs#serve'
  get '/uploads/header/*path' => 'gridfs#serve'

  require 'api'
  mount Youxin::API => '/'

end
