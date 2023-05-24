require 'rails_helper'

RSpec.describe "Create a user", type: :feature do
  scenario "valid inputs" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Welcome! You have signed up successfully.")
  end

  scenario "password too short" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwert"
    fill_in "Password confirmation", with: "qwert"
    click_on "Sign up"
    expect(page).to have_content("Password is too short")
  end

  scenario "no password" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: ""
    fill_in "Password confirmation", with: "qwert"
    click_on "Sign up"
    expect(page).to have_content("Password can't be blank")
  end

  scenario "wrong confirmation password" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "Qwerty"
    click_on "Sign up"
    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  scenario "wrong email format" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "testtest.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Email is invalid")
  end

  scenario "no username" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: ""
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Username can't be blank")
  end

  scenario "registering with already existing username" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    visit root_path
    click_on "Sign out"
    click_on "Sign up"
    fill_in "Email", with: "test1@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Username has already been taken")
  end

  scenario "registering with already existing email" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test1"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    visit root_path
    click_on "Sign out"
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test2"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Email has already been taken")
  end

  scenario "registering with an email as username" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test2@test.com"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Username is invalid")
  end

  scenario "registering with an dots in username" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test.test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Username is invalid")
  end
end
