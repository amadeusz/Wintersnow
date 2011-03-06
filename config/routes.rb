Koliber::Application.routes.draw do

  resources :logs

	# najwyższy priorytet mają wpisy umieszczone od góry

	match '/addresses/unlock' => 'addresses#unlock', :as => 'unlock_addresses', :via => 'get'

	match '/login/create(.:format)' => 'login#create', :via => 'post'
	match '/login/destroy(.:format)' => 'login#destroy', :via => 'get'
	match '/login(.:format)' => 'login#index', :via => 'get'

	match 'wykluj' => 'users#new'
	match 'users/login' => 'users#login'
	match 'users/logout' => 'users#logout'

	match 'rss/of/:id!:rss_pass' => 'rss#of'
	match 'rss/of/:id' => 'rss#of'
	match 'rss/web' => 'rss#web'
	match 'rss/update' => 'rss#update'
	match 'rss' => 'rss#index'
	match 'ustawienia' => 'users#edit'
#	match 'instrukcja' => 'users#manual'
	
	match '/sites(.:format)' => 'sites#index', :as => 'sites', :via => 'get'
#	match '/sites(.:format)' => 'sites#create', :as => 'sites', :via => 'post'
#	match '/sites/new(.:format)' => 'sites#new', :as => 'new_site', :via => 'get'
	match '/sites/:id/edit(.:format)' => 'sites#edit', :as => 'edit_site', :via => 'get'
#	match '/sites/:id(.:format)' => 'sites#show', :as => 'site', :via => 'get'
	match '/sites/:id(.:format)' => 'sites#update', :as => 'site', :via => 'put'
	match '/sites/:id(.:format)' => 'sites#destroy', :as => 'site', :via => 'delete'
	
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
