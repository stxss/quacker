require "rails_helper"

RSpec.describe "Log in a user", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }

  it "with email" do
    visit root_path
    fill_in "Login", with: user.email
    fill_in "Password", with: user.password
    click_on "Log in"
    expect(page).to have_content("Signed in successfully.")
  end

  it "with username" do
    visit root_path
    fill_in "Login", with: user.username
    fill_in "Password", with: user.password
    click_on "Log in"
    expect(page).to have_content("Signed in successfully.")
  end
end
