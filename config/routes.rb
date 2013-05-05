Youxin::Application.routes.draw do
  root to: 'admin/users#index'
  devise_for :users

  namespace :admin do
    resources :users
    post 'users/excel_importor' => 'users#excel_importor'
    resources :organizations do
      get 'members' => 'members#index', on: :member
      put 'members' => 'members#update', on: :member
      delete 'members' => 'members#destroy', on: :member
    end
  end

  get '/uploads/avatar/*path' => 'gridfs#serve'
end
