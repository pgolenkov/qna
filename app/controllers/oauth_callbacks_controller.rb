class OauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = Services::FindForOauth.new(request.env['omniauth.auth']).call
    if @user&.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Github')
    else
      redirect_to root_path, alert: 'Authentication failed'
    end
  end
end
