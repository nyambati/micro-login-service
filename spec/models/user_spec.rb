require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to have_many :assignments }
  it { is_expected.to have_many(:roles).through(:assignments) }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
end
