# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

u1 = User.create(email: "u1@u1.com", password: "qwerty", username: "user1")
u2 = User.create(email: "u2@u2.com", password: "qwerty", username: "user2")
u3 = User.create(email: "u3@u3.com", password: "qwerty", username: "user3")
u4 = User.create(email: "u4@u4.com", password: "qwerty", username: "user4")

Follow.create(follower_id: u1.id, followed_id: u2.id)
Follow.create(follower_id: u2.id, followed_id: u1.id)
Follow.create(follower_id: u3.id, followed_id: u1.id)
Follow.create(follower_id: u4.id, followed_id: u1.id)
