require 'rails_helper'

RSpec.describe "Retweets", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:private_user) { create(:user) }

  before do
    # Set private user display name and visibility
    # login_as private_user
    # visit root_path
    # click_on "Profile"
    # click_on "Edit profile"
    # fill_in "Display name", with: "private user"
    # click_on "Save"
    # visit settings_audience_and_tagging_path
    # check "account_private_visibility"
    # click_on "Protect"
    # visit root_path
    # fill_in "tweet_body", with: "Private account tweet!"
    # click_on "Tweet"

    login_as user
    visit root_path
  end

  it "user can retweet own tweets" do
    visit root_path
    fill_in "tweet_body", with: "Public tweet!"
    click_on "Tweet"
    click_on "rt"
    visit root_path
    within ".retweet-info" do
      expect(page).to have_css("#display-name", text: user.display_name).twice
      expect(page).to have_css("#tweet-body", text: "Public tweet!")
    end
  end

  it "another user can retweet" do
    visit root_path
    fill_in "tweet_body", with: "Public tweet!"
    click_on "Tweet"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    click_on "rt"
    visit root_path
    within ".retweet-info" do
      expect(page).to have_css("#display-name", text: other_user.display_name).once
      expect(page).to have_css("#display-name", text: user.display_name).once
      expect(page).to have_css("#tweet-body", text: "Public tweet!")
    end
  end
end
