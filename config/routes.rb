Youxin::Application.routes.draw do
  root to: 'home#index'
  get 'privacy' => 'home#privacy'
  get 'terms' => 'home#terms'
  get 'welcome' => 'home#welcome'
  get 'hi', to: redirect('/welcome')
  get 'introduction' => 'home#introduction'
  # For mobile
  get 'app' => 'home#app'

  resources :receipts, only: [:index, :show] do
    member do
      put 'read' => 'receipts#read'
      post 'favorite' =>  'receipts#favorite'
      delete 'favorite' => 'receipts#unfavorite'
    end
  end
  get 'r/:short_key' => 'receipts#mobile_show', as: :mobile_receipt
  post 'r/:short_key/c' => 'receipts#mobile_collection_create', as: :mobile_collection
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
      post 'run_call_notifications_now' => 'posts#run_call_notifications_now'
      get 'last_call_scheduler' => 'posts#last_call_scheduler'
      post 'run_call_notifications_to_unfilleds_now' => 'posts#run_call_notifications_to_unfilleds_now'
      post 'run_sms_notifications_to_unfilleds_now' => 'posts#run_sms_notifications_to_unfilleds_now'
    end
    resources :comments, only: [:index, :create]
    resources :attachments, only: [:index]
  end
  resources :attachments, only: [:show, :create]

  resource :account, only: [:show, :update] do
    get 'notifications_counter' => 'accounts#notifications_counter'
    get 'organizations' => 'accounts#organizations'
    get 'authorized_organizations' => 'accounts#authorized_organizations'
    get 'recent_authorized_organizations' => 'accounts#recent_authorized_organizations'
    get 'created_receipts' => 'accounts#created_receipts'
    get 'favorited_receipts' => 'accounts#favorited_receipts'
  end
  devise_for :users, path: 'account', skip: [:sessions], controllers: { passwords: :passwords }
  as :user do
    get 'sign_in' => 'sessions#new', as: :new_user_session
    post 'sign_in' => 'sessions#create', as: :user_session
    match 'sign_out' => 'sessions#destroy', as: :destroy_user_session, via: Devise.mappings[:user].sign_out_via

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

  resource :namespace, only: [:show, :update]

  # Billing
  get 'billing/sms' => 'billing#sms'
  get 'billing/call' => 'billing#call'
  get 'billing/bill_summary' => 'billing#bill_summary'

  # help
  get 'help/positions' => 'help#positions'
  get 'help/roles' => 'help#roles'

  get '/uploads/avatar/*path' => 'gridfs#serve'
  get '/uploads/header/*path' => 'gridfs#serve'
  get '/uploads/logo/*path' => 'gridfs#serve'

  require 'api'
  mount Youxin::API => '/'

end
