class FacebookController < ApplicationController
  before_filter :set_oauth
  
  def redirect 
    if params[:code] && (session[:access_token] = CGI::unescape(@oauth.get_access_token(params[:code]))).present?                                             
      redirect_to(root_path)
    else
      flash[:error] = "#{params['error']['type']}: #{params['error']['message']}"                                                                             
      redirect_to(root_path)
    end
  end

protected
  def get_app_token
    @app_token ||= begin 
      @oauth.get_app_access_token
      app_graph = Koala::Facebook::GraphAPI.new(@app_token)
    end
  end

  def current_user
    # if we logged in using js, get user from cookies, otherwise, get it from session
    # this should fix the issue with user's projects not getting populated on root page
    # if user logs in using redirect
    if @facebook_cookies
      @current_user ||= user_from_cookies
    elsif  session[:access_token]
      @current_user ||= user_from_session
    end
  end

  def user_from_cookies
    return unless @facebook_cookies

    user = User.find_or_initialize_by(:uid => @facebook_cookies['uid'])

    if user.update_attributes(:access_token => @facebook_cookies['access_token'])
      return user
    else
      flash[:error] = "Error creating user!"
      redirect_to(home_path)
    end
  end

  def user_from_session
    # have to make graph since we're getting info from session
    @current_user = User.find_or_initialize_by(:uid => @graph.get_object('me')['id'])
    if @current_user.update_attributes(:access_token => session[:access_token])
      return @current_user
    else
      flash[:error] = "Error creating user!"
      redirect_to(home_path)
    end
  end

  def set_graph
    @graph ||= begin
      Koala::Facebook::GraphAPI.new(@facebook_cookies['access_token']) unless @facebook_cookies.blank?
    end
  end

  def set_oauth
    @oauth ||= begin
      Koala::Facebook::OAuth.new(AppConfig.app_id, AppConfig.secret_key, AppConfig.callback_url)
    end
  end

  def parse_facebook_cookies
    @facebook_cookies ||= @auth.new.get_user_info_from_cookie(cookies)
  end

	def unpack_signed_request
		@signed_request = oauth.parse_signed_request(params['signed_request']) unless params['signed_request'].nil?
	end


end
