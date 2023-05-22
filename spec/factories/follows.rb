FactoryBot.define do
  factory :follow do
    followed_id { create(:user).id }
    follower_id { create(:user).id }
  end
end
