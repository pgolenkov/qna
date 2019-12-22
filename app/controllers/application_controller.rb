class ApplicationController < ActionController::Base
  private
  
  def check_author
    head(:forbidden) unless current_user.author?(question)
  end
end
