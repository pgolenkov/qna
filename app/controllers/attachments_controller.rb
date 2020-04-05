class AttachmentsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @attachment = ActiveStorage::Attachment.find(params[:id])
    authorize! :destroy, @attachment
    if current_user.author?(@attachment.record)
      @attachment.purge
    else
      head(:forbidden)
    end
  end
end
