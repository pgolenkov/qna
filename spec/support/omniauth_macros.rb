module OmniauthMacros
  def mock_auth_hash
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      'provider' => 'github',
      'uid' => '123545',
      'info' => {
        'email' => 'mockuser@email.com',
        'name' => 'mockuser'
      },
      'credentials' => {
        'token' => 'mock_token'
      }
    })

    OmniAuth.config.mock_auth[:vkontakte] = OmniAuth::AuthHash.new({
      'provider' => 'vkontakte',
      'uid' => '123545',
      'info' => {
        'email' => 'mockuser@email.com',
        'name' => 'mockuser'
      },
      'credentials' => {
        'token' => 'mock_token'
      }
    })
  end
end
