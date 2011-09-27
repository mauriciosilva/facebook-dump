Myfacebook::Application.routes.draw do

  match 'welcome', :to => 'welcome#index', 
        :as => :welcome_path, :via => [:get, :post]

  get "base/index"

  root :to => 'base#index'


  ## fb oauth callback
  match "oauth_redirect" => "facebook#redirect", :as => :oauth_redirect



end
