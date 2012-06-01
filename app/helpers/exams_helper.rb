module ExamsHelper
  def exam_owner?
    @exam.owner? current_user
  end
end
