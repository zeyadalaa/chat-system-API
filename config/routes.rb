Rails.application.routes.draw do
  # resources :messages
  # resources :chats
  # resources :applications
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do 
    namespace :v1 do 
      resources :applications, param: :token ,except: [:destroy] do
        resources :chats, param: :number ,except: [:destroy] do
          resources :messages, param: :number ,except: [:destroy]
        end
      end
    end
  end
  
end
