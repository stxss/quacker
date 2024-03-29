require "rails_helper"

RSpec.describe "Check user static pages", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  before do
    Capybara.page.current_window.resize_to(2000, 2000)
    login_as user
    visit root_path
  end

  it "displays user liked posts" do
    posts = create_list(:post, 5, user_id: user.id, body: "Test post")

    visit root_path
    login_as other_user
    visit username_path(user.username)

    # Find the first three posts and like them
    posts[0..2].each do |post|
      within("#post_#{post.id}") do
        find(".like").click
      end
    end

    # Assert that the first three posts are liked
    posts[0..2].each do |post|
      within("#post_#{post.id}") do
        expect(page).not_to have_css(".like .liked")
        expect(page).to have_css(".unlike-button")
      end
    end

    # Assert that the remaining posts are not liked
    posts[3..4].each do |post|
      within("#post_#{post.id}") do
        expect(page).to have_css(".like")
        expect(page).not_to have_css(".unlike-button")
      end
    end

    visit username_path(other_user.username)
    click_on "Likes"
    expect(page).to have_css(".post-body").thrice
  end

  it "displays user posts and reposts" do
    posts = create_list(:post, 10, user_id: user.id, body: "Test post ")

    visit root_path
    login_as other_user
    visit username_path(user.username)

    # Find the first five posts and repost them
    posts[0..4].each do |post|
      within("#post_#{post.id}") do
        find(".reposts .dropdown").click
        find(".repost-button").click
      end
    end

    # Assert that the first five posts are reposted
    posts[0..4].each do |post|
      within("#post_#{post.id}") do
        within ".reposts" do
          find(".dropdown").click
        end
        expect(page).not_to have_css(".repost-button")
        expect(page).to have_css(".unrepost-button")
        find(".backdrop").click
      end
    end

    # Assert that the remaining posts are not reposted
    posts[5..9].each do |post|
      within("#post_#{post.id}") do
        within ".reposts" do
          find(".dropdown").click
        end
        expect(page).to have_css(".repost-button")
        expect(page).not_to have_css(".unrepost-button")
        find(".backdrop").click
      end
    end

    visit username_path(other_user.username)
    expect(page).to have_css(".post-body").exactly(5).times
  end
end
