class AttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_author

  def destroy
    attachment.purge
  end

  private

  def attachment
    @attachment ||= ActiveStorage::Attachment.find(params[:id])
  end

  def check_author
    head(:forbidden) unless current_user.author?(attachment.record)
  end
end
