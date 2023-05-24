require 'rails_helper'

RSpec.describe "Log in a user", type: :feature do
  let!(:user) { create(:user) }

  scenario "with email" do
    visit root_path
    fill_in "Login", with: user.email
    fill_in "Password", with: user.password
    click_on "Log in"
    expect(page).to have_content("Signed in successfully.")
  end

  scenario "with username" do
    visit root_path
    fill_in "Login", with: user.username
    fill_in "Password", with: user.password
    click_on "Log in"
    expect(page).to have_content("Signed in successfully.")
  end
end
