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
    users = params[:user].keys.map {|k| User.find(k.to_i) }
    users.map {|user| Participation.create(:user => user, :exam => exam) }
    exam.reload
    respond_with exam
  end

  def new
    @exam = Exam.new
    @users = User.all
  end


end
