class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?
  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def logged_in?
    current_user != nil
  end

  before_filter :require_valid_user, :except => :welcome
  def require_valid_user
    # Development aid
    session[:user_id] = User.first.id if request.local?

    if session[:user_id].blank?
      redirect_to cas_auth_path
    end
  end

  def welcome
    if logged_in?
      redirect_to exams_path
    end
  end
end
