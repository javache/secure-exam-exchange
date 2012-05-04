class ExamsController < ApplicationController

  respond_to :html

  def index
    # TODO: show exams for the logged in user (which he can fill in)
  end

  def show
    @exam = Exam.find(params[:id])
  end

  def create
    exam = Exam.create!(params[:exam])
    respond_with exam
  end

  def new
    @exam = Exam.new
    @users = User.all
  end


end
