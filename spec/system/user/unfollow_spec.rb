require 'rails_helper'

RSpec.describe "Unfollow", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  before do
    create(:follow, follower_id: user.id, followed_id: other_user.id)
    create(:follow, follower_id: other_user.id, followed_id: user.id)
  end

  it "First unfollows second" do
    login_as user
    visit username_path(other_user.username)
    click_on "Unfollow"
    click_on "Confirm"
    expect(page).to have_button("Follow")
    # expect(user.following).not_to include(other_user)
    # expect(other_user.followers).not_to include(user)
  end

  it "Second unfollows first" do
    login_as other_user
    visit username_path(user.username)
    click_on "Unfollow"
    within("#dialog") do
      click_on "Confirm"
    end
    expect(page).to have_button("Follow")
    # expect(other_user.following).not_to include(user)
    # expect(user.followers).not_to include(other_user)
  end
end
