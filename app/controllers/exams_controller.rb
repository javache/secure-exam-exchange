class ExamsController < ApplicationController
  respond_to :html
  before_filter :can_edit_exam, :except => [:index, :show, :new, :create]
  before_filter :can_view_exam, :only => [:show]

  def index
    @exams_participated = current_user.exams_participated
    @exams_created = current_user.exams_created
  end

  def show
    @exam = Exam.find(params[:id])
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

  def upload_answers
    @participation = @exam.participations.where(:user_id => current_user.id).first

    respond_with @participation
  end

  def download_answers
    @participations = @exam.participations.select { |p| p.answers.present? }

    # TODO: maybe generate one big zip with all the current answers in?
    # See fk-enrolment
  end

  def upload_results
    @exam = Exam.find(params[:id])
    @participations = exam.participations
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
    unless @exam.participant? current_user or @exam.can_edit? current_user
      head :forbidden
    end
  end
end
