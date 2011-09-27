Myfacebook::Application.routes.draw do

  get "base/index"

  root :to => 'base#index'


  ## fb oauth callback
  match "oauth_redirect" => "facebook#redirect", :as => :oauth_redirect



end
