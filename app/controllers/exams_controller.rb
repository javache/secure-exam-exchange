class ExamsController < ApplicationController
  respond_to :html

  def index
    @exams = current_user.exams
    @tests = current_user.tests
  end

  def show
    @exam = Exam.find(params[:id])
  end

  def create
    @exam = Exam.create(params[:exam])
    @exam.user = current_user
    @exam.save
    respond_with @exam
  end

  def new
    @exam = Exam.new
  end

  def edit_users
    @exam = Exam.find params[:id]
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

  def upload_answers
    exam = Exam.find(params[:id])
    @participation = exam.participations.where(:user_id => current_user.id).first

    respond_with @participation
  end

  def download_answers
    exam = Exam.find(params[:id])
    if current_user != exam.user
      raise "you're not allowed to download answers for exams you haven't created"
    end

    @participations = exam.participations.select { |p| p.answers.present? }

    # TODO: maybe generate one big zip with all the current answers in?
    # See fk-enrolment
  end

  def upload_results
    exam = Exam.find(params[:id])
    @participations = exam.participations

  end
end
