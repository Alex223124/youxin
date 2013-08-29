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
    collection do
      get 'members' => 'organizations#members'
    end
    member do
      post 'children' => 'organizations#create_children'
      get 'authorized_users' => 'organizations#authorized_users'
      get 'receipts' => 'organizations#receipts'
    end
    resources :members, only: [:index, :create] do
      collection do
        post 'import' => 'members#import'
        put '/' => 'members#update'
        delete '/' => 'members#destroy'
        put 'role' => 'members#update_role'
        delete 'role' => 'members#destroy_role'
      end
    end
  end
  resources :forms, only: [:create] do
    member do
      get 'download' => 'forms#download'
    end
    resources :collections, only: [:create, :index]
    resource :collection, only: [:show]
  end
  resources :posts, only: [:create] do
    member do
      get 'unread_receipts' => 'posts#unread_receipts'
      get 'forms' => 'posts#forms'
      post 'run_sms_notifications_now' => 'posts#run_sms_notifications_now'
      get 'last_sms_scheduler' => 'posts#last_sms_scheduler'
    end
    resources :comments, only: [:index, :create]
    resources :attachments, only: [:index]
  end
  resources :attachments, only: [:show, :create]

  resource :account, only: [:show, :update] do
    get 'organizations' => 'accounts#organizations'
    get 'authorized_organizations' => 'accounts#authorized_organizations'
    get 'recent_authorized_organizations' => 'accounts#recent_authorized_organizations'
    get 'created_receipts' => 'accounts#created_receipts'
    get 'favorited_receipts' => 'accounts#favorited_receipts'
  end
  devise_for :users, path: 'account', skip: [:sessions], controllers: { passwords: :passwords }
  as :user do
    get 'sign_in' => 'devise/sessions#new', as: :new_user_session
    post 'sign_in' => 'devise/sessions#create', as: :user_session
    match 'sign_out' => 'devise/sessions#destroy', as: :destroy_user_session, via: Devise.mappings[:user].sign_out_via

    get 'account/reset_password_by_sms/new' => 'passwords#new_by_sms', as: :new_user_password_by_sms
    post 'account/reset_password_by_sms/edit' => 'passwords#edit_by_sms', as: :edit_user_password_by_sms
  end

  resources :users, only: [:update, :show] do
    member do
      get 'organizations' => 'users#organizations'
      get 'authorized_organizations' => 'users#authorized_organizations'
      get 'receipts' => 'users#receipts'
    end
  end

  # help
  get 'help/positions' => 'help#positions'
  get 'help/roles' => 'help#roles'

  get '/uploads/avatar/*path' => 'gridfs#serve'
  get '/uploads/header/*path' => 'gridfs#serve'

  require 'api'
  mount Youxin::API => '/'

end
