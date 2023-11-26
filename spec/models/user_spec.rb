require "rails_helper"

RSpec.describe User, type: :model do
  describe "#follow" do
    let!(:first) { create(:user) }
    let!(:second) { create(:user) }

    context "when one user follows another" do
      before do
        create(:follow, follower_id: first.id, followed_id: second.id)
      end

      it "first is following second" do
        expect(first).to be_following(second)
      end

      it "second has first as a follower" do
        expect(second.followers).to include(first)
      end
    end
  end

  describe "#unfollow" do
    let!(:first) { create(:user) }
    let!(:second) { create(:user) }

    context "when one user is following another" do
      before do
        create(:follow, follower_id: first.id, followed_id: second.id)
        first.unfollow(second)
      end

      it "first isn't following second" do
        expect(first).not_to be_following(second)
      end

      it "second doesn't have first as a follower" do
        expect(second.followers).not_to include(first)
      end
    end
  end
end
