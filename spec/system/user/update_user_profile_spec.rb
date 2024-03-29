require "rails_helper"

RSpec.describe "Update user profile fields", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }

  it "on a new sign_up" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    fill_in "Display name", with: "display name for user"
    fill_in "Biography", with: "a simple biography"
    click_on "Save"
    within ".access-buttons" do
      click_on "Profile"
    end
    expect(page).to have_css(".display-name", text: "display name for user")
    expect(page).to have_css(".bio", text: "a simple biography")
  end

  it "when visiting profile page and clicking on edit" do
    login_as user
    visit root_path
    click_on "I'll do it later"
    click_on "Profile"
    click_on "Edit profile"
    fill_in "Display name", with: "2nd display name for user"
    fill_in "Biography", with: "2nd simple biography"
    click_on "Save"
    expect(page).to have_css(".display-name", text: "2nd display name for user")
    expect(page).to have_css(".bio", text: "2nd simple biography")
  end

  it "when visiting edit profile page url" do
    login_as user
    visit root_path
    visit "/settings/profile"
    fill_in "Display name", with: "3rd display name for user"
    fill_in "Biography", with: "3rd simple biography"
    click_on "Save"
    within ".access-buttons" do
      click_on "Profile"
    end
    expect(page).to have_css(".display-name", text: "3rd display name for user")
    expect(page).to have_css(".bio", text: "3rd simple biography")
  end
end
