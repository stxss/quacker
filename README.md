# Quacker

# Table of Contents
1. [Table of Contents](#table-of-contents)
2. [Description](#description)
3. [Why?](#-why)
4. [Features](#-features)
4. [Quick Start](#-quick-start)
5. [Contribution](#-contribution)
6. [Personal Note](#-personal-note)

## Description
A website where you can quack and yap out your opinions that I'm sure a lot of people care about.

## 🧐 Why?
I built my own social media app as I dislike how social media nowadays is in general. This one has no recommendation algorithms (apart from relevance). You won't be bombarded with unnecessary things. It won't try to hook you into topics you don't actively care about. You follow people that you want and see only what you choose to see.

Also this is was a very nice learning opportunity that I used to delve deeper in Rails and understand its inner workings, as this project is a part of the [Ruby On Rails Final Project](https://www.theodinproject.com/lessons/ruby-on-rails-rails-final-project#project-building-facebook) following The Odin Project's curriculum.

## ✨ Features
### Users
- Profile and account editing
- Following
- Notifications
- Blocking
- Muting (users and words)

### Posts
- Creating and deleting posts
- Reposting
- Quoting
- Commenting in a way that makes sense
  - Nested structure, allowing for the creation of threads under a post

### Interaction
- Liking
- Bookmarking
- Pinning a post to the profile
- Real-time messaging
- Groupchats
- Sharing content from within the platform, i.e. when a post with someone, it will be automatically embedded in a message.
- URL parsing, not allowing invalid TLD's to be made into hyperlinks
- Copying posts' links
- Search feature
- Theme customization, with light/dark mode support
- WYSIWYG editor with Markdown support

## 🚀 Quick Start

If you want to replicate this project on your own system, you can follow this guide.

### Clone this repository

If you've never cloned a repository, follow [this GitHub guide](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository).

### All you really need is Docker
As I develop on Linux, I used Docker Compose.
If you're on Linux, I recommend following [this guide](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository). For other OS, you can find the installation steps [here](https://docs.docker.com/compose/install/#installation-scenarios).

### Launch the app

Paste and run this code in your terminal.

`docker compose up`

If you want to run PostgreSQL, Redis, or anything else via a custom `docker-compose.yml` file, you can use the following command:

`docker compose -f docker-compose-example.yml up`

In the second case, you'd need to have ruby and rails installed. and installing Ruby, for some reason, is troublesome in a lot of cases, but I found [this](https://gorails.com/setup/ubuntu/22.04) to be the best walkthroughes

### Prepare the database

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# or you can just run the below command, although it won't apply changes to existing migrations, if you made any.

bin/rails db:prepare
```

### Start posting!

Open up your browser, type in `localhost:3000` and voilà, you're up and running!

### 🎉 That's it! You're ready to use the app!


## 🤝 Contribution

If you want to contribute, first of all, thank you very much! Second of all, you'll need to set the app first. For that you can follow the steps in the [Quick Start Guide](#-quick-start)

### Run the tests

```bash
rspec
```

### Submit a pull request

If you'd like to contribute, please fork the repository and open a pull request to the `main` branch.

## 📝 Personal note

A lot of people have the need to feel their thoughts validated, and for seemingly good reason - who doesn't like validation? A lot of people want to sh*tpost, put out pictures of their perfect lives, try validate their insecurities, or just seek attention in general through social media. Thing is, why ~~would~~ should anybody care?

Social media should be doing what the term suggests it to do, be a medium for social interaction, not its replacement. It should be a way to share our moments, thoughts and feelings with those close to us or those with the same interests, not creating personas for people around the globe to develop unhealthy obsessions centered around that, most of the time, fake persona. It shouldn't be a way to promote businesses and other bullsh*t, where the hell is the social aspect in that?
