Rails.application.routes.draw do
  root 'dashboard#index'

  scope "(:locale)", locale: /en|de/ do

    get 'dashboard/index', format: false

    get 'logout' => 'application#logout', format: false

    resources :domains do
      resources :records, :domainmetadata, :cryptokeys, only: [:index, :new]
      member do
        get :delete
        put :secure
      end
    end

    resources :domainmetadata, except: :index do 
      member do
        get :delete
      end
    end

    resources :records, except: :index do
      member do
        get :delete
        get :clone
        put :generate_token
      end
    end

    resources :cryptokeys, except: :index do
      member do
        get :delete
      end
    end

    resources :users do
      member do
        get :delete
      end
    end

#    resources :comments do
#      member do
#        get :delete
#      end
#    end
#
#    resources :tsigkeys do
#      member do
#        get :delete
#      end
#    end

    put 'tokenized_update/:id/:token' => 'records#tokenized_update',
      format: :true,
      constraints: {format: :json},
      defaults: {format: :json}

  end

  get '/:locale' => 'dashboard#index', format: false

end
