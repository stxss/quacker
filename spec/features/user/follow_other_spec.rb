require 'rails_helper'

RSpec.describe "Follow", type: :feature, driver: :selenium do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:third_user) { create(:user) }

  before do
    visit root_path
    fill_in "Login", with: user.email
    fill_in "Password", with: user.password
    click_on "Log in"
  end

  scenario "First doesn't follow second" do
    visit username_path(other_user.username)
    click_on "Follow"
    expect(user.following).to include(other_user)
    expect(other_user.followers).to include(user)
  end

  scenario "Second doesn't follow first" do
    visit root_path
    click_on "Sign out"
    fill_in "Login", with: other_user.email
    fill_in "Password", with: other_user.password
    click_on "Log in"
    visit username_path(user.username)
    click_on "Follow"
    expect(other_user.following).to include(user)
    expect(user.followers).to include(other_user)
  end

  scenario "invalid follow" do
    visit root_path
    visit username_path(third_user.username)
    User.find_by(username: third_user.username).destroy
    click_on "Follow"
    expect(page).to have_content("Oops, something went wrong")
    expect(other_user.following).not_to include(third_user)
  end
end
