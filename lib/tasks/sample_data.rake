namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_admin
    make_users
    make_friendships
  end
end

def make_admin
  User.create!(name: "Andrew Ledvina",
                 email: "wvvwwvw@gmail.com",
                 password: "foobar",
                 password_confirmation: "foobar",
                 admin: true)
end

def make_users
  99.times do |n|
    name  = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password  = "password"
    User.create!(name:     name,
                 email:    email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_friendships
  users = User.all
  user  = users.first
  friends             = users[2..10]
  pending_users       = users[21..40]
  requests_from_users = users[11..20]

  friends.each do |friend|
    Friendship.request(friend, user)
    Friendship.accept(user, friend)
  end

  pending_users.each do |pending|
    Friendship.request(user, pending)
  end

  requests_from_users.each do |requestor|
    Friendship.request(requestor, user)
  end
end