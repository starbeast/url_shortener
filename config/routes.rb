Rails.application.routes.draw do
  get '/:shortened_url' => 'urls#redirect', as: 'redirect'

  scope :api, defaults: { format: :json }, path: 'api' do
    resources :api_tokens, only: [:create, :index, :destroy]
    resources :urls, only: [:create, :index, :destroy]
    post '/login' => 'sessions#login'
    post '/signup' => 'sessions#sign_up'
    get '/logout' => 'sessions#logout'
  end
end
