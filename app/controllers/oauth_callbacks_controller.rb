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

  def vkontakte
    @user = Services::FindForOauth.new(request.env['omniauth.auth']).call
    if @user && @user.email.blank?
      authorization = @user.authorizations.find_by!(provider: 'vkontakte')
      return redirect_to edit_user_path(provider: 'vkontakte', uid: authorization.uid)
    end

    if @user&.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Vkontakte')
    else
      redirect_to root_path, alert: 'Authentication failed'
    end
  end
end
