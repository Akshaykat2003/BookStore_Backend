Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do 
      # User Authentication Routes
      post 'users/signup', to: 'users#signup'
      post 'users/login', to: 'users#login'
      post 'users/forgot_password', to: 'users#forgot_password'
      post 'users/reset_password', to: 'users#reset_password'

      # Book Routes (Defined explicitly)
      post 'books/create', to: 'books#create'
      get 'books', to: 'books#index'
      get 'books/:id', to: 'books#show'
      put 'books/:id', to: 'books#update'
      delete 'books/:id', to: 'books#destroy'

      # Custom Book Routes
      patch 'books/:id/is_deleted', to: 'books#is_deleted'
    end
  end
end
