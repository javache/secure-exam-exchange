module ExamsHelper
  def can_edit_exam?
    @exam.can_edit? current_user
  end

  def can_submit_exam?
    @exam.in_progress? && (@exam.participant? current_user)
  end
end
