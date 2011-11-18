VaeSurvey31::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "users/registrations"} do
    get 'users/enable', :to => "users/registrations#enable", :as => "enable_user"
    get 'users', :to => "users/registrations#index", :as => "users"
  end

  root :to => "cifs#home"

  match 'reports', :to => 'reports#index', :as => 'reports'
  match 'reports/request', :to => 'reports#request', :as => 'request_report'
  match 'reports/pulse', :to => 'reports#pulse', :as => 'pulse'
  match 'reports/get', :to => 'reports#report', :as => 'get_report'

  match 'seasons/:id/enable', :to => 'seasons#enable', :as => 'enable_season'
  match 'seasons/:id/disable', :to => 'seasons#disable', :as => 'disable_season'
  match 'seasons/:id/send', :to => 'seasons#send', :as => 'send_season'
  match 'thank_you_cards/:id/:passcode/view', :to => 'thank_you_cards#view', :as => 'view_tyc'

  match 'cifs/include', :to => 'cifs#include', :as => 'include_survey'
  match 'cifs/declude', :to => 'cifs#declude', :as => 'declude_survey'
  match 'surveys/access/:id/:passcode', :to => 'cifs#access', :as => 'access_survey'
  match 'surveys/fill', :to => 'cifs#fill', :as => 'fill_survey'
  match 'cifs/flag', :to => 'cifs#flag', :as => 'flag_survey'
  match 'cifs/send', :to => 'cifs#send', :as => 'send_survey'
  match 'cifs/capture', :to => 'cifs#capture', :as => 'capture_survey'
  match 'cifs/review', :to => 'cifs#review', :as => 'review_survey'
  match 'cifs/resend', :to => 'cifs#resend', :as => 'resend_survey'

  resources :companies, :except => :destroy
  resources :clients, :except => :create
  resources :cifs
  resources :thank_you_cards
  resources :prop_seasons
  resources :seasons
  resources :properties
  resources :groups, :except => [:create, :show]


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
