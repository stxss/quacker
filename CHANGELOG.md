# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [Unreleased]

### Changed

-   A lot of changes related to `Rails 7.1.1`, take a look at [this commit](https://github.com/stxss/odin-twitter/commit/2b8fdc2fe469aea29c8f14fb3f8057510da2308c)
-   Introduced decent `.env` variables
-   Updated Dockerfile

#### Languages and services
- Update `Ruby` to `3.2.2`
-   Update `Node` to `20.x`
-   Update `Postgres` to `16.0`
-   Update `Redis` to `7.2.3`

#### Back-end dependencies

-   Update `cssbundling-rails` to `1.3.0`
-   Update `jsbundling-rails` to `1.2.0`
-   Update `puma` to `6.4.0`
-   Update `rack-mini-profiler` to `3.1.1`
-   Update `rails` to `7.1.1`
-   Update `redis` to `5.0.7`
-   Update `sidekiq` to `7.1.6`
-   Update `stimulus-rails` to `1.3.0`
-   Update `turbo-rails` to `1.5.0`

#### Front-end dependencies

-   Update `autoprefixer` to `10.4.16`
-   Update `esbuild` to `0.19.5`
-   Update `postcss` to `8.4.31`
-   Update `tailwindcss` to `3.3.5`

### Added

-   This `CHANGELOG.md`

### Fixed

-   Node installation in Dockerfile

### Removed

## [0.4.0] - 2022-11-02

### Added

-   Option to share link of a tweet
-   Bookmark functionality
-   Introduce error handling when trying to interact with tweets that are deleted/protected
-   Buttons to default page layout
-   User replies page
-   Setup for `Docker`
-   `Tailwind CSS`
-   Relevance algorithm for tweets
-   Autofocus for some text input fields
-   Conversations and Messages systems
-   Expand/hide replies in comment threads
-   Mute accounts feature
-   Mute words feature
-   Block accounts feature
-   Search in messages feature
-   Search for tweets feature
-   Users can private only their likes while maintaining public profile
-   Share a tweet in the direct messages, with the tweet having a custom embed in the chat
-   Placeholder host, at the moment it is `https://example.com`

### Fixed

-   Users now can't send notifications to themselves
-   Clear text area when submitting tweet
-   Duplicate flash message generation, now it only appears once
-   Some N+1 queries
-   Deleting a parent tweet now doesn't cause any breaks, soft delete was introduced
-   Record update when adding comments
-   Routes have more purposeful naming
-   Autoscroll to the end of the conversation when sending a new message
-   Broadcasting to only specific users
-   Minor notification bugs
-   User liked tweets page
-   Calculations for comment root/depth
-   Follow requests working properly

### Changed

-   Comments now have a similar layout to reddit, a more cascade-like/nested layout
-   Migrate from importmaps to esbuild
-   Default/initial display name is now equal to the username

## [0.3.0] - 2022-08-13

### Added

-   Retweets system with `Turbo` functionality
-   Possibility to delete tweets
-   Some edge cases handling, e.g:
    -   User trying to retweet/like deleted tweet
-   Page links
-   Activity box for likes/retweets/comment links and counts
-   Quote functionality
-   Comment functionality
-   Compose Tweet, Quote modals
-   Styling to like and retweet buttons
-   Real time updates of the counts/buttons
-   Broadcasts
-   Text compression for faster page loading
-   Trap focus
-   Backdrop when opening modals
-   Button that shows more information/actions on tweets

### Fixed

-   Validation that was breaking the tweet creation feature
-   Flaky tests
-   Likes adding extra DOM elements

### Changed

-   Controllers from `Tweet` to:

    -   Tweet
    -   Retweet
    -   Quotes
    -   Comments

-   Root path to `/home`
-   Edit profile form on users' first login to the page

#### Back-end dependencies

-   Update `rails` from `7.0.4.3` to `7.0.7`
-   Update `stimulus-rails` from `1.2.1` to `1.2.2`
-   Update `puma` from `5.6.5` to `5.6.6`
-   Update `capybara` from `3.39.1` to `3.39.2`
-   Replaced `webdrivers` by `selenium-webdriver`
-   Update `rack-mini-profiler` to `3.1.1`
-   Update `spring` to `4.1.1`
-   Update `standard-rails` to `0.1.0`
-   Update `redis` to `4.8.1`
-   Update `rubocop` to `1.56.0`
-   Update `irb` to `1.7.4`

### Removed

-   Retweets Controller

## [0.2.0] - 2022-06-12

### Added

#### Models and Controllers:

-   User
-   Like
-   Tweet
-   Retweet
-   Follow
-   Notification
-   Account

#### User features:

-   Sign-In using either e-mail or username
-   Profile editing
-   Profile page
-   Visibility
-   Custom modals for unfollows
-   Private Follow Requests system

#### Account settings:

-   Audience and Tagging
-   Tagging
-   Your Tweets
-   Content You See
-   Search
-   Mute and Block
-   Block Imports
-   Muted Accounts
-   Muted Keywords
-   Advanced Filters for Notifications
-   Direct Messages

#### Tweet creation and display:

-   User timeline only shows tweets from people they follow
-   Stimulus controller to check tweet length and change submission button accordingly
-   Add character counter to tweet form

#### Other features

-   Likes system
-   Time formatting
-   Basic CSS styling

#### Tests:

-   User Creation
-   Following Users
-   Logging In
-   Accounts
-   Tweets

### Changed

-   Feature -> System (tests naming)

### Removed

-   Unfollow notifications

## [0.1.0] - 2022-05-19

-   Initial app setup

[Unreleased]: https://github.com/stxss/odin-twitter/compare/0.4.0...HEAD
[0.4.0]: https://github.com/stxss/odin-twitter/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/stxss/odin-twitter/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/stxss/odin-twitter/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/stxss/odin-twitter/releases/tag/0.1.0
