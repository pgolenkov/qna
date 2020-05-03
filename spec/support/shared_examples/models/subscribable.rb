RSpec.shared_examples 'subscribable' do
  it { should have_many(:subscriptions).dependent(:destroy) }
end
