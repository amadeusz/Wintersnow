Koliber::Application.routes.draw do

	# najwyższy priorytet mają wpisy umieszczone od góry

#	match 'addresses', :to => 'addresses#index', :via => 'get'
#	match 'addresses(/:klucz(/:action(.:format)))', :to => 'addresses#destroy', :via => 'delete'
#	match 'addresses(/:klucz(/:action(.:format)))', :to => 'addresses#:action'
#	
#	
##	match 'addresses/:klucz/:action' => 'addresses#:action'
##	

	match 'users/login' => 'users#login'
	match 'users/login_admin' => 'users#login_admin'
	match 'users/logout' => 'users#logout'

	match 'rss/of/:id' => 'rss#of'
	match 'rss/web/:id' => 'rss#web'
	match 'rss/test/:id' => 'rss#test'
	match 'rss' => 'rss#index'
	
	match "/addresses(.:format)" => "addresses#index", :as => 'addresses'
	match "/addresses(.:format)" => "addresses#create", :as => 'addresses'
	match "/addresses/new(.:format)" => "addresses#new", :as => 'new_address'
	match "/addresses/:klucz/edit(.:format)" => "addresses#edit", :as => 'edit_address'
	match "/addresses/:klucz(.:format)" => "addresses#show", :as => 'address'
	match "/addresses/:klucz(.:format)" => "addresses#update", :as => 'address'
	match "/addresses/:klucz(.:format)" => "addresses#destroy", :as => 'address'
	match "/users(.:format)" => "users#index", :as => 'users'
	match "/users(.:format)" => "users#create", :as => 'users'
	match "/users/new(.:format)" => "users#new", :as => 'new_user'
	match "/users/:id/edit(.:format)" => "users#edit", :as => 'edit_user'
	match "/users/:id(.:format)" => "users#show", :as => 'user'
	match "/users/:id(.:format)" => "users#update", :as => 'user'
	match "/users/:id(.:format)" => "users#destroy", :as => 'user'
	
	root :to => "rss#index"
	
	resources :messages, :genotypes

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

	# This is a legacy wild controller route that's not recommended for RESTful applications.
	# Note: This route will make all actions in every controller accessible via GET requests.
	# match ':controller(/:action(/:id(.:format)))'
end
