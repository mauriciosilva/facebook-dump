class WelcomeController < FacebookController
  before_filter :unpack_signed_request
  def index
    @user = User.find_or_initialize_by(@signed_request) unless @signed_request.nil? 
    @user.save
  end

end
