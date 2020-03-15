class Services::FindForOauth
  attr_reader :auth

  def initialize(auth)
    @auth = auth
  end

  def call
    authorization = Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)
    return authorization.user if authorization

    email = auth.info.email || ''
    if email.present?
      user = User.find_by(email: email)
    end

    unless user
      password = Devise.friendly_token[0, 20]
      user = User.new(email: email, password: password, password_confirmation: password)
      if email.present?
        user.skip_confirmation!
        user.save!
      else
        user.save!(validate: false)
      end
    end

    user.authorizations.create!(provider: auth.provider, uid: auth.uid.to_s)
    user
  end

end
