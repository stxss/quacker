require 'rails_helper'

RSpec.describe "Log in a user", type: :feature do
  let!(:user) { create(:user) }

  scenario "with email" do
    visit root_path
    fill_in "Login", with: user.email
    fill_in "Password", with: user.password
    click_on "Log in"
    expect(page).to have_content("Home\nExplore\nNotifications\nMessages\nBookmarks\nProfile\nSettings\nSign out")
  end

  scenario "with username" do
    visit root_path
    fill_in "Login", with: user.username
    fill_in "Password", with: user.password
    click_on "Log in"
    expect(page).to have_content("Home\nExplore\nNotifications\nMessages\nBookmarks\nProfile\nSettings\nSign out")
  end
end
