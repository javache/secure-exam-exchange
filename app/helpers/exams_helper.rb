module ExamsHelper
  def can_edit_exam?
    @exam.can_edit? current_user
  end
end
