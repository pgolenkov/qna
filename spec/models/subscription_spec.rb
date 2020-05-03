require 'rails_helper'

RSpec.describe Subscription, type: :model do
  subject { build :subscription }
  it { should belong_to(:user) }
  it { should belong_to(:subscribable) }
  it { should validate_uniqueness_of(:user).scoped_to(:subscribable_type, :subscribable_id) }
end
