require 'rails_helper'

RSpec.describe "Update user account settings", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }

  it "changes the protect tweets setting" do
    login_as user
    visit settings_audience_and_tagging_path
    check "account_private_visibility"
    click_on "Protect"
    visit username_path(user.username)
    expect(page).to have_css("#icon-lock")
  end

  it "when phototagging OFF" do
    login_as user
    visit settings_tagging_path
    check "account_allow_media_tagging"
    visit settings_audience_and_tagging_path
    expect(page).to have_css("#current-tagging-setting")
  end

  it "when the phototagging ON setting is set to default of anyone" do
    login_as user
    visit settings_tagging_path
    check "account_allow_media_tagging"
    visit settings_audience_and_tagging_path
    expect(page).to have_css("#current-tagging-setting", text: "Anyone can tag you")
  end

  it "when the phototagging ON setting is set to only people you follow" do
    login_as user
    visit settings_tagging_path
    check "account_allow_media_tagging"
    choose "account_allow_media_tagging_only_people_you_follow"
    visit settings_audience_and_tagging_path
    expect(page).to have_css("#current-tagging-setting", text: "Only people you follow can tag you")
  end

  xit "when a user has sensitive media, a warning is displayed" do
  end

  xit "when a user allows sensitive media to appear, no warning is issued" do
  end

  xit "when a user hides sensitive media from the search results" do
  end

  xit "when a user removes blocked/muted accounts from search" do
  end

  xit "when a user blocks someone" do
  end

  xit "when a user mutes someone" do
  end

  xit "when a user mutes words" do
  end

  xit "when a user mutes notifications from people that they don't follow" do
  end

  xit "when a user mutes notifications from people who don't follow them" do
  end

  xit "when a user mutes notifications from people with a new account" do
  end

  xit "when a user mutes notifications from people with a default profile picture" do
  end

  xit "when a user mutes notifications from people who haven't confirmed their email" do
  end

  xit "when a user allows message requests only from people they follow" do
  end

  xit "when a user allows message requests from everyone" do
  end

  xit "when a user has message receipts off" do
  end

  xit "when a user has message receipts on" do
  end
end
