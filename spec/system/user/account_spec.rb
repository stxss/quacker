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

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end

  xit "" do
  end
end

