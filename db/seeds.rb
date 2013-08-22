# encoding: utf-8

namespace1 = Namespace.create name: 'namespace-one'
namespace2 = Namespace.create name: 'namespace-two'

p '-'*70
p 'For namespace1'

organization1 = Organization.new name: 'uestc', bio: 'bio-usetc'
organization1.namespace = namespace1
organization1.save

organization2 = organization1.children.new name: 'scie', bio: 'bio-scie'
organization2.namespace = namespace1
organization2.save
organization3 = organization2.children.new name: 'networking', bio: 'bio-networking'
organization3.namespace = namespace1
organization3.save
organization4 = organization2.children.new name: 'information', bio: 'bio-information'
organization4.namespace = namespace1
organization4.save
organization5 = organization2.children.new name: 'communication', bio: 'bio-communication'
organization5.namespace = namespace1
organization5.save

organization6 = organization1.children.new name: 'see', bio: 'bio-see'
organization6.namespace = namespace1
organization6.save
organization7 = organization6.children.new name: 'eie', bio: 'bio-eie'
organization7.namespace = namespace1
organization7.save
organization8 = organization6.children.new name: 'efrt', bio: 'bio-efrt'
organization8.namespace = namespace1
organization8.save
organization9 = organization6.children.new name: 'ewta', bio: 'bio-ewta'
organization9.namespace = namespace1
organization9.save
organization10 = organization6.children.new name: 'ict', bio: 'bio-ict'
organization10.namespace = namespace1
organization10.save

password = '12345678'

10.times do |n|
  name = "name-#{n}"
  phone = 18600000000 + n
  bio = "bio-#{n}"
  gender = %w(男 女).sample
  qq = 10000 + n
  blog = "blog-#{n}"
  uid = 123456 + n
  namespace1.users.create name: name,
                          email: "#{n}@a.a",
                          password: password,
                          password_confirmation: password,
                          phone: phone,
                          bio: bio,
                          gender: gender,
                          qq: qq,
                          blog: blog,
                          uid: uid
end
namespace1.positions.create name: "学生"
namespace1.positions.create name: "老师"
namespace1.positions.create name: "教授"
namespace1.positions.create name: "院长"
namespace1.positions.create name: "辅导员"

namespace1.organizations.each do |organization|
  times = rand(10)
  times.times do
    organization.add_member(namespace1.users[rand(10)], namespace1.positions[rand(5)])
  end
end

admin1 = namespace1.users.first
admin2 = namespace1.users.last
actions = Action.options_array
# organization1.authorize_cover_offspring(admin1, actions)
# organization2.authorize_cover_offspring(admin2, actions)

admin_role = namespace1.roles.create name: '管理员', actions: actions
admin1.user_role_organization_relationships.create organization_id: organization1.id, role_id: admin_role.id
admin2.user_role_organization_relationships.create organization_id: organization2.id, role_id: admin_role.id


posts = []
posts << %(I wish the rest of my life could move as slowly as the people working for American Airlines' lost baggage department.)
posts  << %w{Nice walk down memory lane :)RT @drewcpu: The Pebble team has come a long way in 3 years: http://imgur.com/1gjPoNQ }
posts << %{At #NordicGame Conference and have a question about MongoDB? Sign up for one of our Ask The Experts spots. Just stop by our stand!}
posts << %{Looking for a hostel, guesthouse or budget hotel? Need a recommendation? Send us a tweet! #AskHostelworld}
posts << %{How do you land an engineering job? "ABC: Always Be Coding" by @guitardave24 https://medium.com/tech-talk/d5f8051afce2?utm_source=TwitterAccount&utm_medium=Twitter&utm_campaign=TwitterAccount …}

admins = [admin1, admin2]

10.times do |n|
  organizations = []
  7.times do
    organizations |= [namespace1.organizations.sample]
  end
  post = admins.sample.posts.new organization_ids: organizations.map(&:id), body_html: posts.sample
  post.save
end


# ---------------namespace2-------------------
p '-'*70
p 'For namespace2'

namespace2_organization = namespace2.organizations.create name: 'organization-namespace', bio: 'organization-namespace'

namespace2_user = namespace2.users.create name: 'name',
                                          email: "namespace@a.a",
                                          password: '123456',
                                          password_confirmation: '123456',
                                          phone: '18683255555',
                                          bio: 'namespace-bio',
                                          gender: '男',
                                          qq: '100000',
                                          blog: 'namespace-blog',
                                          uid: '2900000001'

namespace2.positions.create name: "position_one"
namespace2.positions.create name: "position_two"
namespace2_organization.add_member(namespace2_user, namespace2.positions[rand(2)])

namespace2_actions = Action.options_array

namespace2_role = namespace2.roles.create name: '管理员', actions: namespace2_actions
namespace2_user.user_role_organization_relationships.create organization_id: namespace2_organization.id, role_id: namespace2_role.id

p '-'*70
p 'Done!'
