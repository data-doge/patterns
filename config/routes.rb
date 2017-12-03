Logan::Application.routes.draw do
  resource :inbox, :controller => 'inbox', :only => [:show,:create]
  resources :gift_cards do
    collection do
      get 'recent_signups', action: :recent_signups, as: :recent_signups
      get 'modal/:giftable_type/:giftable_id', action: :modal, as: :modal
    end
  end

  resources :mailchimp_updates
  namespace :public do
    resources :people, only: [:new, :create, :deactivate] do
      get '/deactivate/:token', to:'people#deactivate', as: :deactivate
    end
  end

  resources :invitations do
    resources :comments, controller: 'comments'
  end

  resources :research_sessions, path: :sessions, has_many: :invitations do
    resources :comments, controller: 'comments'
    get 'invitations_panel',
      to: 'research_sessions#invitations_panel',
      as: :invitations_panel
    get 'add_person/:person_id',
      to: 'research_sessions#add_person',
      as: :add_person
    resources :invitations do
      collection do
        post ':id/event/:event',
              to: 'invitations#event',
              as: :event

        get ':id/confirm/(:token)',
              to: 'invitations#confirm',
              as: :remote_confirm

        get ':id/cancel/(:token)',
              to: 'invitations#cancel',
              as: :remote_cancel
      end
      resources :comments, controller: 'comments'
    end
  end

  resources :sms_invitations, only: [:create]


  # simple session based cart for storing people ids.
  get 'cart', to: 'cart#index', as: :show_cart
  get 'cart/add/:person_id', to: 'cart#add', as: :add_cart
  get 'cart/delete(/:person_id(/:all))', to: 'cart#delete', as: :delete_cart

  get 'carts/all', to: 'cart#carts', as: :all_carts
  post 'carts/change/:name', to: 'cart#change', as: :change_cart
  post 'carts/delete/:name', to: 'cart#delete_cart', as: :cart_delete
  get 'registration', to: 'public/people#new'

  post 'update_tags/:token/', to: 'people#update_tags', as: :update_tags_post
  get 'update_tags/:token/', to: 'people#update_tags', as: :update_tags_get

  resources :twilio_wufoos

  resources :twilio_messages do
    collection do
      post 'newtwil'
      get 'newtwil'
      post 'uploadnumbers'
      get 'sendmessages'
    end
  end

  post 'receive_text/index', defaults: { format: 'xml' }
  post 'receive_text/smssignup', defaults: { format: 'xml' }

  # post "twilio_messages/updatestatus", to: 'twilio_messages/#updatestatus'

  # post "twil", to: 'twilio_messages/#newtwil'

  get 'taggings/create', as: :tag_create
  get 'taggings/destroy', as: :tag_destroy
  get 'taggings/search', as: :tag_search

  get 'mailchimp_export/index'
  get 'mailchimp_export/create'
  resources :reservations

  resources :events do
    member do
      post :export
    end
  end

  resources :applications
  resources :programs

  # weirdo stuff to get around devise. has to be a better way

  devise_for :users

  scope "/admin" do
    resources :users
    get 'changes', to: 'users#changes', as: :user_changes
  end

  get 'dashboard/index'
  resources :submissions

  resources :comments
  resources :taggings, only: [:create, :destroy]

  get 'calendar/event_slots.json(:token)', to: 'calendar#event_slots', defaults: { format: 'json' }

  get 'calendar/reservations.json(:token)', to: 'calendar#reservations', defaults: { format: 'json' }
  get 'calendar/events.json', to: 'calendar#events', defaults: { format: 'json' }

  get '/calendar/(:id)', to: 'calendar#show', as: :calendar
  get '/calendar/(:token)/feed/', to: 'calendar#feed', defaults: { format: 'ics' }
  get '/calendar/show_actions/:id/(:token)',
      to: 'calendar#show_actions',
      defaults: { format: 'js' },
      as: :calendar_show_actions

  get '/calendar/show_reservation/:id/(:token)',
      to: 'calendar#show_reservation',
      defaults: { format: 'js' },
      as: :calendar_show_reservation

  get '/calendar/show_invitation/:id/(:token)',
      to: 'calendar#show_invitation',
      defaults: { format: 'js' },
      as: :calendar_show_invitation

  get '/calendar/show_event/:id/(:token)',
      to: 'calendar#show_event',
      defaults: { format: 'js' },
      as: :calendar_show_event



  get  'search/index'
  get  'search/index_ransack'
  post 'search/index_ransack'
  post 'search/export_ransack'
  post 'search/export' # send search results elsewhere, i.e. Mailchimp
  post 'search/exportTwilio'
  get  'search/advanced', to: 'search#advanced', as: :advanced_search
  post  'search/advanced', to: 'search#advanced', as: :advanced_search_post

  get 'mailchimp_exports/index'

  resources :people do
    collection do
      post 'create_sms'
      post ':person_id/deactivate', action: :deactivate, as: :deactivate
    end
    resources :comments
    resources :gift_cards
  end
  # post "people/create_sms"

  get 'activate/:number/:code',
    to: 'gift_cards#activate',
    defaults: { format: 'xml' }


  match "/delayed_job" => DelayedJobWeb, anchor: false, via: [:get, :post]

  root to: 'dashboard#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
