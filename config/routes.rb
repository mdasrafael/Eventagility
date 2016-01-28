Rails.application.routes.draw do

  root 'pages#home'

  devise_for  :users,
              :path => '',
              :path_names => {:sign_in => 'login', :sign_out => 'logout', :edit => 'profile'},
              :controllers => {
                                :omniauth_callbacks => 'omniauth_callbacks',
                                :registrations => 'registrations'
                              }

  resources :users, only: [:show]
  resources :spaces
  resources :photos
  resources :spaces do
    resources :bookings, only: [:create]
  end

  resources :spaces do
    resources :reviews, only: [:create, :destroy]
  end

  get '/preload' => 'bookings#preload'
  get '/preview' => 'bookings#preview'

  get '/your_bookings' => 'bookings#your_bookings'
  get '/your_events' => 'bookings#your_events'

  post '/notify' => 'bookings#notify'
  post '/your_events' => 'bookings#your_events'

  get '/search' => 'pages#search'

end
