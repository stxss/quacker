require 'rails_helper'

RSpec.describe "Tweet creation", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }

  before do
    login_as user
    visit root_path
  end

  it "creates a normal tweet" do
    visit root_path
    fill_in "tweet_body", with: "First tweet!"
    click_on "Tweet"
    expect(page).to have_css("#tweet-body", text: "First tweet!")
  end

  it "creates a tweet with a single character" do
    fill_in "tweet_body", with: "1"
    click_on "Tweet"
    expect(page).to have_css("#tweet-body", text: "1")
  end

  it "doesn't create a tweet with only whitespace characters" do
    fill_in "tweet_body", with: "     "
    expect(page).not_to have_css("#real-submit-tweet")
    expect(page).to have_css("#fake-submit-tweet")
  end

  it "does create a tweet with exactly 280 characters" do
    exact_limit_tweet = Faker::Hipster.paragraph_by_chars(characters: 280)
    fill_in "tweet_body", with: exact_limit_tweet
    click_on "Tweet"
    expect(page).to have_css("#tweet-body", text: exact_limit_tweet)
  end

  it "doesn't create a tweet with more than 280 of characters" do
    fill_in "tweet_body", with: Faker::Hipster.paragraph_by_chars(characters: 281)
    expect(page).not_to have_css("#real-submit-tweet")
    expect(page).to have_css("#fake-submit-tweet")
  end

  it "shows a tweet created minutes ago" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_tweet =  user.created_tweets.create(body: content)
    test_tweet.update(created_at: 2.minutes.ago)
    visit root_path
    expect(page).to have_css("#tweet-body", text: content)
    expect(page).to have_css("#created-time", text: "2 min")
  end

  it "shows a tweet created hours ago" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_tweet =  user.created_tweets.create(body: content)
    test_tweet.update(created_at: 2.hours.ago)
    visit root_path
    expect(page).to have_css("#tweet-body", text: content)
    expect(page).to have_css("#created-time", text: "2 h")
  end

  it "shows a tweet created this year" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_tweet =  user.created_tweets.create(body: content)
    test_tweet.update(created_at: Date.new(Time.zone.now.year, 4, 7))
    visit root_path
    expect(page).to have_css("#tweet-body", text: content)
    expect(page).to have_css("#created-time", text: "Apr 7")
  end

  it "shows a tweet created last year" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_tweet =  user.created_tweets.create(body: content)
    test_tweet.update(created_at: Date.new(Time.zone.now.year - 1, 11, 7))
    visit root_path
    expect(page).to have_css("#tweet-body", text: content)
    expect(page).to have_css("#created-time", text: "Nov 7, #{Time.zone.now.year - 1}")
  end

  it "shows the tweet when clicking on the content" do
    fill_in "tweet_body", with: "First tweet!"
    click_on "Tweet"
    find("#tweet-body").click
    expect(page).to have_css("#tweet-body", text: "First tweet!")
  end

  xit "deletes tweet" do

  end
end
