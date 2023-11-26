require "rails_helper"

RSpec.describe "Post creation", type: :system do
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

  it "creates a normal post" do
    visit root_path
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    expect(page).to have_css(".post-body", text: "First post!")
  end

  it "can visit post" do
    post = create(:post, user_id: user.id, body: "Test post")
    visit single_post_path(username: user.username, id: post.id)
    expect(page).to have_content("Test post")
  end

  it "creates a post with a single character" do
    visit root_path
    fill_in "compose-area", with: "1"
    click_on "Post"
    expect(page).to have_css(".post-body", text: "1")
  end

  it "doesn't create a post with only whitespace characters" do
    fill_in "compose-area", with: "     "
    expect(page).not_to have_css(".real-submit-post")
    expect(page).to have_css(".fake-submit-post")
  end

  it "doesn't create a post with more than 280 of characters" do
    # exact_limit_post = Faker::Hipster.paragraph_by_chars(characters: 280)
    # fill_in "compose-area", with: exact_limit_post
    fill_in "compose-area", with: "very big much text to 280 chars.
    very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much text to 280 chars. very big much s"
    # find(:id, "compose-area").send_keys "."
    expect(page).to have_css(".fake-submit-post")
    expect(page).not_to have_css(".real-submit-post")
  end

  it "does create a post with exactly 280 characters" do
    visit root_path
    exact_limit_post = Faker::Hipster.paragraph_by_chars(characters: 280)
    fill_in "compose-area", with: exact_limit_post
    click_on "Post"
    expect(page).to have_css(".post-body", text: exact_limit_post)
  end

  it "shows a post created minutes ago" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_post = user.created_posts.create(body: content)
    test_post.update(created_at: 2.minutes.ago)
    visit root_path
    expect(page).to have_css(".post-body", text: content)
    expect(page).to have_css(".created-time", text: "2 min")
  end

  it "shows a post created hours ago" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_post = user.created_posts.create(body: content)
    test_post.update(created_at: 2.hours.ago)
    visit root_path
    expect(page).to have_css(".post-body", text: content)
    expect(page).to have_css(".created-time", text: "2 h")
  end

  it "shows a post created this year" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_post = user.created_posts.create(body: content)
    test_post.update(created_at: Date.new(Time.zone.now.year, 4, 7))
    visit root_path
    expect(page).to have_css(".post-body", text: content)
    expect(page).to have_css(".created-time", text: "Apr 7")
  end

  it "shows a post created last year" do
    content = Faker::Hipster.paragraph_by_chars(characters: 100)
    test_post = user.created_posts.create(body: content)
    test_post.update(created_at: Date.new(Time.zone.now.year - 1, 11, 7))
    visit root_path
    expect(page).to have_css(".post-body", text: content)
    expect(page).to have_css(".created-time", text: "Nov 7, #{Time.zone.now.year - 1}")
  end

  it "shows the post when clicking on the content" do
    visit root_path
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    find(".post-body").click
    expect(page).to have_css(".post-body", text: "First post!")
  end

  it "when author, shows delete button" do
    visit root_path
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    visit username_path(user.username)
    find(".more-info-button").click
    expect(page).to have_button("Delete")
  end

  it "when author can delete post" do
    visit root_path
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    visit username_path(user.username)
    find(".more-info-button").click
    click_on "Delete"
    within "#turbo-confirm" do
      click_on "Delete"
    end
    expect(page).not_to have_css(".post-body", text: "First post!")
  end

  it "when not author doesn't show delete button" do
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    expect(page).not_to have_button("Delete")
  end

  it "posts have like button" do
    visit root_path
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    expect(page).to have_css(".like")
  end

  it "authors can like their own posts" do
    visit root_path
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    visit username_path(user.username)
    find(".like").click
    expect(page).to have_css(".unlike-button")
  end

  it "users can like others' posts" do
    visit root_path
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    find(".like").click
    expect(page).to have_css(".unlike-button")
  end

  it "users can unlike posts" do
    visit root_path
    fill_in "compose-area", with: "First post!"
    click_on "Post"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    find(".like").click
    find(".unlike-button").click
    expect(page).to have_css(".like")
  end

  it "users cannot like deleted posts" do
    visit root_path
    fill_in "compose-area", with: "Public post!"
    click_on "Post"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    user.created_posts.last.destroy
    find(".like").click
    expect(page).to have_content("Couldn't like a deleted post.")
  end

  it "user can repost own posts" do
    visit root_path
    fill_in "compose-area", with: "Public post!"
    click_on "Post"
    within ".reposts" do
      find(".dropdown").click
      find(".repost-button").click
    end
    visit root_path
    within ".repost-info" do
      expect(page).to have_css(".display-name", text: user.display_name).twice
      expect(page).to have_css(".post-body", text: "Public post!")
    end
  end

  it "another user can repost" do
    visit root_path
    fill_in "compose-area", with: "Public post!"
    click_on "Post"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    within ".reposts" do
      find(".dropdown").click
      find(".repost-button").click
    end
    visit root_path
    within ".repost-info" do
      expect(page).to have_css(".display-name", text: other_user.display_name).once
      expect(page).to have_css(".display-name", text: user.display_name).once
      expect(page).to have_css(".post-body", text: "Public post!")
    end
  end

  it "user can't repost deleted post" do
    visit root_path
    fill_in "compose-area", with: "Public post!"
    click_on "Post"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    user.created_posts.last.destroy
    within ".reposts" do
      find(".dropdown").click
      find(".repost-button").click
    end
    expect(page).to have_content("Couldn't repost a deleted post.")
  end

  it "user can unrepost" do
    visit root_path
    fill_in "compose-area", with: "Public post!"
    click_on "Post"
    visit root_path
    login_as other_user
    visit username_path(user.username)
    within ".reposts" do
      find(".dropdown").click
      find(".repost-button").click
    end
    visit root_path
    within ".reposts .reposted" do
      find(".dropdown").click
      find(".unrepost-button").click
    end
    expect(page).not_to have_css(".display-name", text: other_user.display_name).once
    expect(page).not_to have_css(".display-name", text: user.display_name).once
    expect(page).not_to have_css(".post-body", text: "Public post!")
  end

  it "users cannot repost posts from private users" do
    create(:follow, followed_id: other_user.id, follower_id: user.id, is_request: false)
    create(:follow, followed_id: user.id, follower_id: other_user.id, is_request: false)

    visit root_path
    login_as user
    visit settings_audience_and_tagging_path
    check "account_private_visibility"
    click_on "Protect"
    visit root_path
    create(:post, user_id: user.id, body: "Test post")

    visit root_path
    login_as other_user
    visit username_path(user.username)
    within ".reposts" do
      expect(page).not_to have_css(".dropdown")
      expect(page).not_to have_css(".unrepost-button")
    end
  end

  it "users can unrepost posts from private users they had previously reposted" do
    create(:follow, followed_id: other_user.id, follower_id: user.id, is_request: false)
    create(:follow, followed_id: user.id, follower_id: other_user.id, is_request: false)
    create(:post, user_id: user.id, body: "Test post")

    visit root_path

    login_as other_user
    visit username_path(user.username)
    within ".reposts" do
      find(".dropdown").click
      find(".repost-button").click
    end

    visit root_path
    login_as user
    visit settings_audience_and_tagging_path
    check "account_private_visibility"
    click_on "Protect"

    visit root_path
    login_as other_user
    visit username_path(user.username)

    within ".reposts" do
      expect(page).to have_css(".dropdown")
      expect(page).to have_css(".reposts .reposted")
    end
  end

  it "if a user sets account to private mid-unrepost, a fake repost button replaces the menu" do
    create(:follow, followed_id: other_user.id, follower_id: user.id, is_request: false)
    create(:follow, followed_id: user.id, follower_id: other_user.id, is_request: false)

    visit root_path
    login_as user
    visit root_path
    fill_in "compose-area", with: "Public post!"
    click_on "Post"
    visit root_path

    login_as other_user
    visit username_path(user.username)
    within ".reposts" do
      find(".dropdown").click
      find(".repost-button").click
    end

    visit username_path(user.username)
    user.account.update(private_visibility: true)
    within ".reposts .reposted" do
      find(".dropdown").click
      find(".unrepost-button").click
    end

    within ".reposts" do
      expect(page).not_to have_css(".dropdown")
      expect(page).not_to have_css(".unrepost-button")
    end
  end
end
