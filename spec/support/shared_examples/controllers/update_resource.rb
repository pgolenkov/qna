RSpec.shared_examples 'update resource' do
  let(:resource_name) { resource.class.to_s.underscore.to_sym }

  subject { patch :update, params: { id: resource, resource_name => update_attributes }, format: :js }

  describe 'by authenticated user' do
    before { login(user) }

    context 'his resource with valid params' do
      it 'should change resource' do
        subject
        resource.reload
        update_attributes.each do |attr_name, value|
          expect(resource.send(attr_name)).to eq value
        end
      end
      it { should render_template(:update) }
    end

    context 'with attached files' do
      it 'should attach files to resource' do
        patch :update, params: { id: resource, resource_name => { files: [fixture_file_upload('spec/spec_helper.rb')] } }, format: :js
        expect(resource.reload.files).to be_attached
      end
    end

    context 'his resource with invalid params' do
      subject { patch :update, params: { id: resource, resource_name => invalid_attributes }, format: :js }

      it 'should not change resource' do
        update_attributes.keys.each do |attr_name|
          expect { subject }.to_not change(resource, attr_name)
        end
      end

      it { should render_template(:update) }
    end

    context "another user's resource" do
      let!(:another_resource) { create resource_name }
      subject { patch :update, params: { id: another_resource, resource_name => update_attributes, format: :js } }
      before { subject }

      it 'should not change resource' do
        update_attributes.keys.each do |attr_name|
          expect { subject }.to_not change(another_resource, attr_name)
        end
      end

      it 'should return forbidden status' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'by unauthenticated user' do
    it 'should not change resources`s attributes' do
      update_attributes.keys.each do |attr_name|
        expect { subject }.to_not change(resource, attr_name)
      end
    end

    it 'should return unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
