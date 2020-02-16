require 'rails_helper'

RSpec.describe UserAward, type: :model do
  it { should belong_to :user }
  it { should belong_to :award }
end
