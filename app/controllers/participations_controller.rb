class ParticipationsController < ApplicationController
  respond_to :html
  before_filter :can_edit_participation

  def show
    respond_with @participation
  end

  def update
    # TODO: check if exam is still avaiable for participation
    @participation.attributes = params[:participation]
    @participation.save

    respond_with @participation
  end

  def upload_answers
    @participation.answers = params[:participation][:answers]
    @participation.save

    @participation.generate_upload_proof(current_user) do |path|
      send_file path, type: @participation.answers.content_type
    end
  end

  def upload_results
    @participation.results = params[:participation][:results]
    @participation.save
    respond_with @participation
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
