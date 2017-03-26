Rails.application.routes.draw do
  root to: 'home#index'

  namespace :api do
    namespace :v1 do
      resources :certificates, param: :serial, only: %i(create)
      post '/certificates/:serial/revoke', to: 'certificates#revoke', as: :certificate_revoke
    end
  end
end
