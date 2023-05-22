require 'rails_helper'

RSpec.describe "Follow", type: :feature do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  before do
    visit root_path
    fill_in "Login", with: user.email
    fill_in "Password", with: user.password
    click_on "Log in"
  end

  scenario "First doesn't follow second" do
    visit username_url(other_user.username)
    click_on "Follow"
    expect(user.following).to include(other_user)
    expect(other_user.followers).to include(user)
  end

  scenario "Second doesn't follow first" do
    click_on "Sign out"
    visit root_path
    fill_in "Login", with: other_user.email
    fill_in "Password", with: other_user.password
    click_on "Log in"
    visit username_url(user.username)
    click_on "Follow"
    expect(other_user.following).to include(user)
    expect(user.followers).to include(other_user)
  end
end
