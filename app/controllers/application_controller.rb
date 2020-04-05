class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    head :forbidden
  end
end
