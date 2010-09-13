Koliber::Application.routes.draw do

	# najwyższy priorytet mają wpisy umieszczone od góry

	match '/login/create(.:format)' => 'login#create', :via => 'post'
	match '/login/destroy(.:format)' => 'login#destroy', :via => 'get'
	match '/login(.:format)' => 'login#index', :via => 'get'

	match 'wykluj' => 'users#new'
	match 'users/login' => 'users#login'
	match 'users/logout' => 'users#logout'

	match 'rss/of/:id' => 'rss#of'
	match 'rss/web' => 'rss#web'
	match 'rss/test/:id' => 'rss#test'
	match 'rss' => 'rss#index'
	
#	match '/addresses(.:format)' => 'addresses#index', :as => 'addresses', :via => 'get'
#	match '/addresses(.:format)' => 'addresses#create', :as => 'addresses', :via => 'post'
#	match '/addresses/new(.:format)' => 'addresses#new', :as => 'new_address', :via => 'get'
#	match '/addresses/:klucz/edit(.:format)' => 'addresses#edit', :as => 'edit_address', :via => 'get'
#	match '/addresses/:klucz(.:format)' => 'addresses#show', :as => 'address', :via => 'get'
#	match '/addresses/:klucz(.:format)' => 'addresses#update', :as => 'address', :via => 'put'
#	match '/addresses/:klucz(.:format)' => 'addresses#destroy', :as => 'address', :via => 'delete'
#	match '/users(.:format)' => 'users#index', :as => 'users', :via => 'get'
#	match '/users(.:format)' => 'users#create', :as => 'users', :via => 'post'
#	match '/users/new(.:format)' => 'users#new', :as => 'new_user', :via => 'get'
#	match '/users/:id/edit(.:format)' => 'users#edit', :as => 'edit_user', :via => 'get'
#	match '/users/:id(.:format)' => 'users#show', :as => 'user', :via => 'get'
#	match '/users/:id(.:format)' => 'users#update', :as => 'user', :via => 'put'
#	match '/users/:id(.:format)' => 'users#destroy', :as => 'user', :via => 'delete'
	
	resources :addresses, :genotypes, :messages, :users
	root :to => 'login#index'
	
end
