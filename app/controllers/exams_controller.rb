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
end
