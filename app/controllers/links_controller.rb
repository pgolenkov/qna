class LinksController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @link = Link.find(params[:id])
    if current_user.author?(@link.linkable)
      @link.destroy
    else
      head(:forbidden)
    end
  end
end
