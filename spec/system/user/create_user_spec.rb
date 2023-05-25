require 'rails_helper'

RSpec.describe "Create a user", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  it "valid inputs" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Welcome! You have signed up successfully.")
  end

  it "password too short" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwert"
    fill_in "Password confirmation", with: "qwert"
    click_on "Sign up"
    expect(page).to have_content("Password is too short")
  end

  it "no password" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: ""
    fill_in "Password confirmation", with: "qwert"
    click_on "Sign up"

    message = page.find("#user_password").native.attribute("validationMessage")

    expect(message).to have_text("Please fill out this field")
  end

  it "wrong confirmation password" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "Qwerty"
    click_on "Sign up"
    expect(page).to have_content("Password confirmation doesn't match Password")
  end

  it "wrong email format" do
    visit root_path
    click_on "Sign up"

    test_email = "testtest.com"
    fill_in "Email", with: "testtest.com"

    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"

    message = page.find("#user_email").native.attribute("validationMessage")

    expect(message).to have_text("Please include an '@' in the email address. '#{test_email}' is missing an '@'.")
  end

  it "no username" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: ""
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"

    message = page.find("#user_username").native.attribute("validationMessage")

    expect(message).to have_text("Please fill out this field")
  end

  it "registering with already existing username" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    click_on "Sign out"
    click_on "Sign up"
    fill_in "Email", with: "test1@test.com"
    fill_in "Username", with: "test"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Username has already been taken")
  end

  it "registering with already existing email" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test1"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    click_on "Sign out"
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test2"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Email has already been taken")
  end

  it "registering with an email as username" do
    visit root_path
    click_on "Sign up"
    fill_in "Email", with: "test@test.com"
    fill_in "Username", with: "test2@test.com"
    fill_in "Password", with: "qwerty"
    fill_in "Password confirmation", with: "qwerty"
    click_on "Sign up"
    expect(page).to have_content("Username is invalid")
  end

  it "registering with an dots in username" do
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
