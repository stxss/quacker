require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#follow" do
    let!(:first) { create(:user) }
    let!(:second) { create(:user) }

    before do
      create(:follow, follower_id: first.id, followed_id: second.id)
    end

    it "creates a following" do
      expect(first).to be_following(second)
    end
  end
end
