module ExamsHelper
  def current_user_created?
    current_user == @exam.user
  end
end
