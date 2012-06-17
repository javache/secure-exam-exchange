class ParticipationsController < ApplicationController
  respond_to :html
  before_filter :can_edit_participation

  def show
    respond_with @participation
  end

  def update
    # TODO: check if exam is still avaiable for participation
    # TODO: this method will also be used for results submission
    #if @participation.answers.present? && params[:participation][:answers]
    #  head :forbidden
    #else
      @participation.attributes = params[:participation]
      @participation.save
      respond_with @participation
    #end
  end

  private

  def can_edit_participation
    @participation = Participation.find(params[:id])
    @exam = @participation.exam
    unless @participation.exam.can_edit? current_user ||
           @participation.user == current_user
      head :forbidden
    end
  end
end
