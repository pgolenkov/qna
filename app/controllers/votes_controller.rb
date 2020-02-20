class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_votable, only: :create

  def create
    vote = @votable.votes.build(user: current_user, status: params[:status])
    respond_to do |format|
      if vote.save
        format.json do
          render json: { vote: vote }, status: :created
        end
      else
        format.json do
          render json: { errors: vote.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    vote = Vote.find(params[:id])
    respond_to do |format|
      if vote.user_id == current_user.id
        vote.destroy!
        format.json { render json: { vote: vote }, status: :ok }
      else
        format.json { head :forbidden }
      end
    end
  end

  private

  def find_votable
    @votable ||= params[:votable_type].classify.constantize.find(params[:votable_id])
  end
end
