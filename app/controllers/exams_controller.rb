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
    exam = Exam.create(params[:exam])

    exam.user = current_user
    exam.save

    users = User.find params[:user].keys.map(&:to_i)
    exam.add_users users

    respond_with exam
  end

  def new
    @exam = Exam.new
    @users = User.all
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
end
