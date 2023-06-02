require 'rails_helper'

RSpec.describe "Update user account settings", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end
  let!(:user) { create(:user) }

  it "creates a normal tweet" do
    login_as user
    visit root_path
    fill_in "tweet_body", with: "First tweet!"
    click_on "Tweet"
    expect(page).to have_css("#tweet", text: "First tweet!")
  end

  it "creates a tweet with a single character" do
    login_as user
    visit root_path
    fill_in "tweet_body", with: "1"
    click_on "Tweet"
    expect(page).to have_css("#tweet", text: "1")
  end

  it "doesn't create a tweet with 0 non-space characters" do
    login_as user
    visit root_path
    fill_in "tweet_body", with: "     "
    click_on "Tweet"
    expect(page).not_to have_css("#tweet", text: "     ")
  end

end
