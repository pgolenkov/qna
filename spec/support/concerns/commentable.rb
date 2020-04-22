RSpec.shared_examples "commentable" do
  it { should have_many(:comments).order(:created_at).dependent(:destroy) }
end
