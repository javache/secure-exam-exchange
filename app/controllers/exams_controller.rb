class ExamsController < ApplicationController

  respond_to :html

  def index
    # TODO: only show exams for the logged in user (which he can fill in)
    @exams = Exam.all
  end

  def show
    @exam = Exam.find(params[:id])
  end

  def create
    exam = Exam.create!(params[:exam])

    users = User.find params[:user].keys.map(&:to_i)
    exam.add_users users

    respond_with exam
  end

  def new
    @exam = Exam.new
    @users = User.all
  end


end
