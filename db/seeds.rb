# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

orgnization1 = Organization.create name: 'uestc'

orgnization2 = Organization.create name: 'scie', parent: orgnization1
orgnization3 = Organization.create name: 'networking', parent: orgnization2
orgnization4 = Organization.create name: 'information', parent: orgnization2
orgnization5 = Organization.create name: 'communication', parent: orgnization2

orgnization6 = Organization.create name: 'see', parent: orgnization1
orgnization7 = Organization.create name: 'eie', parent: orgnization6
orgnization8 = Organization.create name: 'efrt', parent: orgnization6
orgnization9 = Organization.create name: 'ewta', parent: orgnization6
orgnization10 = Organization.create name: 'ict', parent: orgnization6

password = '12345678'
10.times do |n|
  name = "#{n}"
  User.create name: name, email: "#{name}@a.a", password: password, password_confirmation: password
end
Organization.all.each do |orgnization|
  times = rand(10)
  times.times do
    orgnization.add_member(User.all[rand(10)])
  end
end

admin1 = User.first
admin2 = User.last
actions = Action.options_array
orgnization1.authorize_cover_offspring(admin1, actions)
orgnization2.authorize_cover_offspring(admin2, actions)

posts = []
posts << %(I wish the rest of my life could move as slowly as the people working for American Airlines' lost baggage department.)
posts  << %w{Nice walk down memory lane :)RT @drewcpu: The Pebble team has come a long way in 3 years: http://imgur.com/1gjPoNQ }
posts << %{At #NordicGame Conference and have a question about MongoDB? Sign up for one of our Ask The Experts spots. Just stop by our stand!}
posts << %{Looking for a hostel, guesthouse or budget hotel? Need a recommendation? Send us a tweet! #AskHostelworld}
posts << %{How do you land an engineering job? "ABC: Always Be Coding" by @guitardave24 https://medium.com/tech-talk/d5f8051afce2?utm_source=TwitterAccount&utm_medium=Twitter&utm_campaign=TwitterAccount …}

admins = [admin1, admin2]

10.times do |n|
  orgnizations = []
  7.times do
    orgnizations |= [Organization.all.sample]
  end
  post = admins.sample.posts.new organization_ids: orgnizations.map(&:id), body_html: posts.sample
  post.save
end