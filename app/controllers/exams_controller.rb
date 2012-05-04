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
    respond_with exam
  end

  def new
    @exam = Exam.new
    @users = User.all
  end


end
