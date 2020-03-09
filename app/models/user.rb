class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:github]

  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :authorizations, dependent: :destroy

  has_many :awards

  def self.find_for_oauth(data)
    authorization = Authorization.find_by(provider: data.provider, uid: data.uid.to_s)
    return authorization.user if authorization

    email = data.info.email
    user = User.find_by(email: email)
    unless user
      password = Devise.friendly_token[0, 20]
      user = User.create!(email: email, password: password, password_confirmation: password)
    end

    user.authorizations.create!(provider: data.provider, uid: data.uid.to_s)
    user
  end

  def author?(record)
    record.user_id == id
  end
end
