require 'rails_helper'

RSpec.describe "Follow", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:third_user) { create(:user) }

  it "First doesn't follow second" do
    login_as user
    visit username_path(other_user.username)
    click_on "Follow"
    visit root_path
    click_on "Sign out"
    login_as other_user
    click_on "Follow requests"
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
    User.find_by(username: third_user.username).destroy
    click_on "Follow"
    expect(page).to have_content("Oops, something went wrong")
  end
end
