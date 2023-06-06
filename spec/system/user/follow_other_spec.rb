require 'rails_helper'

RSpec.describe "Follow", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:third_user) { create(:user) }
  let!(:private_user) { create(:user) }

  before do
    login_as private_user
    visit settings_audience_and_tagging_path
    check "account_private_visibility"
    click_on "Protect"
    visit root_path
  end

  it "First doesn't follow second and second is a public account" do
    login_as user
    visit username_path(other_user.username)
    click_on "Follow"
    expect(page).to have_button("Unfollow")
    expect(page).not_to have_button("Follow")
  end

  it "Second doesn't follow first" do
    login_as other_user
    visit username_path(user.username)
    click_on "Follow"
    expect(page).to have_button("Unfollow")
    expect(page).not_to have_button("Follow")
  end

  it "invalid follow" do
    login_as other_user
    visit username_path(third_user.username)
    third_user.destroy
    click_on "Follow"
    expect(page).to have_content("Oops, something went wrong")
  end

  it "following private user prompts a cancel button" do
    login_as user
    visit username_path(private_user.username)
    click_on "Follow"
    visit root_path
    visit username_path(private_user.username)
    expect(page).to have_button("Cancel")
    expect(page).not_to have_button("Follow")
    expect(page).not_to have_button("Unfollow")
  end

  it "private user has a Follow Requests button" do
    login_as user
    visit username_path(private_user.username)
    click_on "Follow"
    visit root_path
    logout
    login_as private_user
    visit root_path
    expect(page).to have_button("Follow Requests")
  end

  it "private user declines follow request" do
    login_as user
    visit username_path(private_user.username)
    click_on "Follow"
    logout
    login_as private_user
    click_on "Follow Requests"
    within "#follow-requester" do
      click_on "Decline"
    end
    visit root_path
    logout
    login_as user
    visit username_path(private_user.username)
    expect(page).to have_button("Follow")
  end

  it "private user accepts follow request" do
    login_as user
    visit username_path(private_user.username)
    click_on "Follow"
    visit root_path
    logout
    login_as private_user
    visit root_path
    click_on "Follow Requests"
    within "#follow-requester" do
      click_on "Accept"
    end
    visit root_path
    logout
    login_as user
    visit username_path(private_user.username)
    expect(page).to have_button("Unfollow")
  end
end
