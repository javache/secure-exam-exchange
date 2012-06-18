class ParticipationsController < ApplicationController
  respond_to :html
  before_filter :can_edit_participation

  def show
    respond_with @participation
  end

  def update
    # user is participant
    if params[:participation] and @participation.user == current_user
      if @participation.answers.present?
        return head :forbidden
      else
        @participation.answers = params[:participation][:answers]
      end
    end

    # user is examinator
    if params[:participation] and @exam.can_edit? current_user
      if @participation.results.present?
        return head :forbidden
      else
        @participation.results = params[:participation][:results]
      end
    end

    @participation.save
    respond_with @participation
  end

  def proof
    @participation.generate_upload_proof(current_user) do |path|
      send_file path
    end
  end

  def answers
    send_file @participation.answers.path,
      :filename => "#{@participation.user.name}-answers.zip"
  end

  def results
    send_file @participation.results.path,
      :filename => "#{@participation.user.name}-results.zip"
  end

  private

  def can_edit_participation
    @participation = Participation.find(params[:id])
    @exam = @participation.exam
    unless @exam.can_edit? current_user ||
           @participation.user == current_user
      head :forbidden
    end
  end
end
