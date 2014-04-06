FactoryGirl.define do
  factory :user do
    name     "Steve Fakerson"
    email    "steve@fake.com"
    password "foobar123"
    password_confirmation "foobar123"
  end
end