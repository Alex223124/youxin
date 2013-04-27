Youxin::Application.routes.draw do
  root to: 'admin/users#index'
  devise_for :users

  namespace :admin do
    resources :users
  end

  get '/uploads/avatar/*path' => 'gridfs#serve'
end
