require 'rails_helper'

RSpec.describe "Check user static pages", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  before do
    Capybara.page.current_window.resize_to(2000, 2000)
  end

  before do
    login_as user
    visit root_path
  end

  it "displays user liked tweets" do
    tweets = create_list(:tweet, 5, user_id: user.id, body: "Test tweet")

    visit root_path
    login_as other_user
    visit username_path(user.username)

    # Find the first three tweets and like them
    tweets[0..2].each do |tweet|
      within("#tweet_#{tweet.id}") do
        find(".like").click
      end
    end

    # Assert that the first three tweets are liked
    tweets[0..2].each do |tweet|
      within("#tweet_#{tweet.id}") do
        expect(page).not_to have_css(".like .liked")
        expect(page).to have_css(".unlike-button")
      end
    end

    # Assert that the remaining tweets are not liked
    tweets[3..4].each do |tweet|
      within("#tweet_#{tweet.id}") do
        expect(page).to have_css(".like")
        expect(page).not_to have_css(".unlike-button")
      end
    end

    visit username_path(other_user.username)
    click_on "Likes"
    expect(page).to have_css(".tweet-body").thrice
  end

  it "displays user tweets and retweets" do
    tweets = create_list(:tweet, 10, user_id: user.id, body: "Test tweet ")

    visit root_path
    login_as other_user
    visit username_path(user.username)

    # Find the first five tweets and retweet them
    tweets[0..4].each do |tweet|
      within("#tweet_#{tweet.id}") do
        find(".retweets .dropdown").click
        find(".retweet-button").click
      end
    end

    # Assert that the first five tweets are retweeted
    tweets[0..4].each do |tweet|
      within("#tweet_#{tweet.id}") do
        within ".retweets" do
          find(".dropdown").click
        end
        expect(page).not_to have_css(".retweet-button")
        expect(page).to have_css(".unretweet-button")
        find(".backdrop").click
      end
    end

    # Assert that the remaining tweets are not retweeted
    tweets[5..9].each do |tweet|
      within("#tweet_#{tweet.id}") do
        within ".retweets" do
          find(".dropdown").click
        end
        expect(page).to have_css(".retweet-button")
        expect(page).not_to have_css(".unretweet-button")
        find(".backdrop").click
      end
    end

    visit username_path(other_user.username)
    expect(page).to have_css(".tweet-body").exactly(5).times
  end
end
