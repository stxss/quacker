require 'rails_helper'

RSpec.describe "Unfollow", type: :feature do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  before do
    create(:follow, follower_id: user.id, followed_id: other_user.id)
    create(:follow, follower_id: other_user.id, followed_id: user.id)
    visit root_path
    fill_in "Login", with: user.email
    fill_in "Password", with: user.password
    click_on "Log in"
  end

  scenario "First unfollows second" do
    visit username_url(other_user.username)
    click_on "Unfollow"
    expect(user.following).not_to include(other_user)
    expect(other_user.followers).not_to include(user)
  end

  scenario "Second unfollows first" do
    click_on "Sign out"
    fill_in "Login", with: other_user.email
    fill_in "Password", with: other_user.password
    click_on "Log in"
    visit username_url(user.username)
    # expect(page).not_to have_selector(:link_or_button, :exact_text => "Follow")
    click_on "Unfollow"
    expect(other_user.following).not_to include(user)
    expect(user.followers).not_to include(other_user)
  end
end
