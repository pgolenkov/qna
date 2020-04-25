RSpec.shared_examples 'API create resource' do
  context 'authorized' do
    let(:user) { User.find(access_token.resource_owner_id) }

    context 'with valid params' do
      it 'should create new resource' do
        expect { subject }.to change { resource_class.count }.by(1)
      end

      it 'should set user attribute to resource owner' do
        subject
        expect(resource.user).to eq user
      end

      it 'should broadcast new resource to channel' do
        expect { subject }.to have_broadcasted_to(channel_name).with(resource)
      end
    end

    context 'with invalid params' do
      let(:params) { invalid_params }

      it 'should not create new question' do
        expect { subject }.not_to change { resource_class.count }
      end

      it 'should not broadcast to channel' do
        expect { subject }.not_to have_broadcasted_to(channel_name)
      end

      it 'returns unprocessable entity status' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors in json' do
        subject
        expect(json['errors']).to be_present
        expect(json['errors'].first).to eq "#{invalid_attribute} can't be blank"
      end
    end
  end
end
