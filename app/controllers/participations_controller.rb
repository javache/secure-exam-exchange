class ParticipationsController < ApplicationController

  respond_to :html

  def show
    @participation = Participation.find(params[:id])
    respond_with @participation
  end

  def update
    @participation = Participation.find(params[:id])

    if @participation.answers.present? && params[:participation][:answers]
      raise "you cannot upload answers twice"
    end
    @participation.answers = params[:participation][:answers]
    @participation.save

    respond_with @participation
  end

  def upload_results
    @participation = Participation.find params[:id]
  end
end
