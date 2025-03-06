Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
namespace :api do
  namespace :v1 do 

    post 'signup',to: 'users#signup'
    post 'login', to: 'users#login'

    post "forgot_password", to: "users#forgot_password"
    post "reset_password", to: "users#reset_password"
  end
end
end
