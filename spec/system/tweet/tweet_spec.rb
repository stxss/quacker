require 'rails_helper'

RSpec.describe "Tweet creation", type: :system do
  before do
    driven_by :selenium_chrome_headless
    # driven_by :selenium_chrome
  end

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:private_user) { create(:user) }

  before do
    login_as user
    visit root_path
  end

  it "creates a normal tweet" do
    visit root_path
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    expect(page).to have_css(".tweet-body", text: "First tweet!")
  end

  it "can visit tweet" do
    tweet = create(:tweet, user_id: user.id, body: "Test tweet")
    visit single_tweet_path(username: user.username, id: tweet.id)
    expect(page).to have_content("Test tweet")
  end

  it "creates a tweet with a single character" do
    visit root_path
    fill_in "compose-area", with: "1"
    click_on "Tweet"
    expect(page).to have_css(".tweet-body", text: "1")
  end

  it "doesn't create a tweet with only whitespace characters" do
    fill_in "compose-area", with: "     "
    expect(page).not_to have_css(".real-submit-tweet")
    expect(page).to have_css(".fake-submit-tweet")
  end

  it "doesn't create a tweet with more than 280 of characters" do
    # exact_limit_tweet = Faker::Hipster.paragraph_by_chars(characters: 280)
    # fill_in "compose-area", with: exact_limit_tweet
    fill_in "compose-area", with: "very big much text to 280 chars.
    very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much s"
    # find(:id, "compose-area").send_keys "."
    expect(page).to have_css(".fake-submit-tweet")
    expect(page).not_to have_css(".real-submit-tweet")
  end

  it "does create a tweet with exactly 280 characters" do
    visit root_path
    exact_limit_tweet = Faker::Hipster.paragraph_by_chars(characters: 280)
    fill_in "compose-area", with: exact_limit_tweet
    click_on "Tweet"
    expect(page).to have_css(".tweet-body", text: exact_limit_tweet)
  end

  it "shows a tweet created minutes ago" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_tweet = user.created_tweets.create(body: content)
    test_tweet.update(created_at: 2.minutes.ago)
    visit root_path
    expect(page).to have_css(".tweet-body", text: content)
    expect(page).to have_css(".created-time", text: "2 min")
  end

  it "shows a tweet created hours ago" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_tweet = user.created_tweets.create(body: content)
    test_tweet.update(created_at: 2.hours.ago)
    visit root_path
    expect(page).to have_css(".tweet-body", text: content)
    expect(page).to have_css(".created-time", text: "2 h")
  end

  it "shows a tweet created this year" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_tweet = user.created_tweets.create(body: content)
    test_tweet.update(created_at: Date.new(Time.zone.now.year, 4, 7))
    visit root_path
    expect(page).to have_css(".tweet-body", text: content)
    expect(page).to have_css(".created-time", text: "Apr 7")
  end

  it "shows a tweet created last year" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_tweet = user.created_tweets.create(body: content)
    test_tweet.update(created_at: Date.new(Time.zone.now.year - 1, 11, 7))
    visit root_path
    expect(page).to have_css(".tweet-body", text: content)
    expect(page).to have_css(".created-time", text: "Nov 7, #{Time.zone.now.year - 1}")
  end

  it "shows the tweet when clicking on the content" do
    visit root_path
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    find(".tweet-body").click
    expect(page).to have_css(".tweet-body", text: "First tweet!")
  end

  it "when author, shows delete button" do
    visit root_path
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    visit username_path(user.username)
    find(".more-info-button").click
    expect(page).to have_button("Delete")
  end

  it "when author can delete tweet" do
    visit root_path
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    visit username_path(user.username)
    find(".more-info-button").click
    click_on "Delete"
    within "#turbo-confirm" do
      click_on "Delete"
    end
    expect(page).not_to have_css(".tweet-body", text: "First tweet!")
  end

  it "when not author doesn't show delete button" do
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    expect(page).not_to have_button("Delete")
  end

  it "tweets have like button" do
    visit root_path
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    expect(page).to have_css(".like")
  end

  it "authors can like their own tweets" do
    visit root_path
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    visit username_path(user.username)
    find(".like").click
    expect(page).to have_css(".unlike-button")
  end

  it "users can like others' tweets" do
    visit root_path
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    find(".like").click
    expect(page).to have_css(".unlike-button")
  end

  it "users can unlike tweets" do
    visit root_path
    fill_in "compose-area", with: "First tweet!"
    click_on "Tweet"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    find(".like").click
    find(".unlike-button").click
    expect(page).to have_css(".like")
  end

  it "users cannot like deleted tweets" do
    visit root_path
    fill_in "compose-area", with: "Public tweet!"
    click_on "Tweet"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    user.created_tweets.last.destroy
    find(".like").click
    expect(page).to have_content("Couldn't like a deleted tweet.")
  end

  it "user can retweet own tweets" do
    visit root_path
    fill_in "compose-area", with: "Public tweet!"
    click_on "Tweet"
    within ".retweets" do
      find(".dropdown").click
      find(".retweet-button").click
    end
    visit root_path
    within ".retweet-info" do
      expect(page).to have_css(".display-name", text: user.display_name).twice
      expect(page).to have_css(".tweet-body", text: "Public tweet!")
    end
  end

  it "another user can retweet" do
    visit root_path
    fill_in "compose-area", with: "Public tweet!"
    click_on "Tweet"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    within ".retweets" do
      find(".dropdown").click
      find(".retweet-button").click
    end
    visit root_path
    within ".retweet-info" do
      expect(page).to have_css(".display-name", text: other_user.display_name).once
      expect(page).to have_css(".display-name", text: user.display_name).once
      expect(page).to have_css(".tweet-body", text: "Public tweet!")
    end
  end

  it "user can't retweet deleted tweet" do
    visit root_path
    fill_in "compose-area", with: "Public tweet!"
    click_on "Tweet"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    user.created_tweets.last.destroy
    within ".retweets" do
      find(".dropdown").click
      find(".retweet-button").click
    end
    expect(page).to have_content("Couldn't retweet a deleted tweet.")
  end

  it "user can unretweet" do
    visit root_path
    fill_in "compose-area", with: "Public tweet!"
    click_on "Tweet"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    within ".retweets" do
      find(".dropdown").click
      find(".retweet-button").click
    end
    visit root_path
    within ".retweets .retweeted" do
      find(".dropdown").click
      find(".unretweet-button").click
    end
    expect(page).not_to have_css(".display-name", text: other_user.display_name).once
    expect(page).not_to have_css(".display-name", text: user.display_name).once
    expect(page).not_to have_css(".tweet-body", text: "Public tweet!")
  end

  it "users cannot retweet tweets from private users" do
    create(:follow, followed_id: other_user.id, follower_id: user.id, is_request: false)
    create(:follow, followed_id: user.id, follower_id: other_user.id, is_request: false)

    visit root_path
    login_as user
    visit settings_audience_and_tagging_path
    check "account_private_visibility"
    click_on "Protect"
    visit root_path
    create(:tweet, user_id: user.id, body: "Test tweet")

    visit root_path
    login_as other_user
    visit username_path(user.username)
    within ".retweets" do
      expect(page).not_to have_css(".dropdown")
      expect(page).not_to have_css(".unretweet-button")
    end
  end

  it "users can unretweet tweets from private users they had previously retweeted" do
    create(:follow, followed_id: other_user.id, follower_id: user.id, is_request: false)
    create(:follow, followed_id: user.id, follower_id: other_user.id, is_request: false)
    create(:tweet, user_id: user.id, body: "Test tweet")

    visit root_path

    login_as other_user
    visit username_path(user.username)
    within ".retweets" do
      find(".dropdown").click
      find(".retweet-button").click
    end

    visit root_path
    login_as user
    visit settings_audience_and_tagging_path
    check "account_private_visibility"
    click_on "Protect"

    visit root_path
    login_as other_user
    visit username_path(user.username)

    within ".retweets" do
      expect(page).to have_css(".dropdown")
      expect(page).to have_css(".retweets .retweeted")
    end
  end

  it "if a user sets account to private mid-unretweet, a fake retweet button replaces the menu" do
    create(:follow, followed_id: other_user.id, follower_id: user.id, is_request: false)
    create(:follow, followed_id: user.id, follower_id: other_user.id, is_request: false)

    visit root_path
    login_as user
    visit root_path
    fill_in "compose-area", with: "Public tweet!"
    click_on "Tweet"
    visit root_path

    login_as other_user
    visit username_path(user.username)
    within ".retweets" do
      find(".dropdown").click
      find(".retweet-button").click
    end

    visit username_path(user.username)
    user.account.update(private_visibility: true)
    within ".retweets .retweeted" do
      find(".dropdown").click
      find(".unretweet-button").click
    end

    within ".retweets" do
      expect(page).not_to have_css(".dropdown")
      expect(page).not_to have_css(".unretweet-button")
    end
  end
end
