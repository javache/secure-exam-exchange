class ExamsController < ApplicationController
  respond_to :html
  before_filter :can_edit_exam, :only => [:edit_users, :unlock]
  before_filter :can_view_exam, :only => [:show, :download]

  def index
    @exams_participated = current_user.exams_participated.select do |exam|
      exam.can_view?(current_user)
    end

    @exams_created = current_user.exams_created
  end

  def show
    @participation = @exam.participations.find { |p| p.user == current_user }
  end

  def create
    @exam = Exam.new(params[:exam])
    @exam.user = current_user
    @exam.save
    respond_with @exam
  end

  def new
    @exam = Exam.new
  end

  def edit_users
    if request.put?
      if params[:user]
        users = User.find params[:user].keys.map(&:to_i)
      else
        users = []
      end

      @exam.edit_users(users)
      redirect_to exam_path(@exam)
    else
      @users = User.where "id != :id", id: current_user.id
    end
  end

  def unlock
    if request.put?
      @exam.unlock(params[:password])
      if @exam.errors.empty? then
        redirect_to exam_path(@exam)
      end
    end
  end

  def download
    if @exam.in_progress?
      @exam.generate_download(current_user) do |file_path|
        send_file file_path, :type => @exam.data.content_type
      end
    else
      head :forbidden
    end
  end

  private

  def can_edit_exam
    @exam = Exam.find params[:id]
    unless @exam.can_edit? current_user
      head :forbidden
    end
  end

  def can_view_exam
    @exam = Exam.find params[:id]
    unless @exam.can_view? current_user
      head :forbidden
    end
  end
end
