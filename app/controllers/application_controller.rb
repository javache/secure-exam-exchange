class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_reader :current_user

  before_filter :require_valid_user
  def require_valid_user
    if session['user_id'].blank?
      redirect_to cas_auth_path
    else
      @current_user = User.find(session['user_id'])
    end
  end
end
