class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    @subscription = current_user.subscriptions.find_or_create_by(subscribable: subscribable)
  end

  private

  def subscribable
    @subscribable ||= params[:subscribable_type].classify.constantize.find(params[:subscribable_id])
  end
end
