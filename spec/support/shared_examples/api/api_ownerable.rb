RSpec.shared_examples 'API ownerable' do
  it 'returns owner as an user' do
    subject
    expect(resource_json['user']['id']).to eq resource.user.id
    expect(resource_json['user']['email']).to eq resource.user.email
  end
end
