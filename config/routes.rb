require 'sidekiq/web'

Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: '_interslice_session'

Rails.application.routes.draw do
  defaults format: :json do
    namespace :api do
      resources :tasks, except: :show do
        post :delete_all, on: :collection, to: 'delete_all_tasks#create'
      end
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'

  get 'healthy', to: 'application_health#index'
end
