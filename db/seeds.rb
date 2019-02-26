require 'faker'

regular_user = User.create_with(name: 'Regular User',
                                password: 'password',
                                password_confirmation: 'password')
                   .find_or_create_by(email: 'regular@example.com')

manager = User.create_with(name: 'Manager',
                           password: 'password',
                           password_confirmation: 'password',
                           manager: true)
              .find_or_create_by(email: 'manager@example.com')

if (count = regular_user.issues.count) < 30
  (30 - count).times do
    regular_user.issues.create(title: Faker::Lorem.sentence,
                               description: Faker::Lorem.paragraph)
  end
end

issues_in_progress = regular_user.issues.first(5)
issues_in_progress.each{|i| i.update!(manager: manager)}
issues_in_progress.each{|i| i.update!(status: 'in_progress')}

resolved_issues = regular_user.issues.last(10)
resolved_issues.each{|i| i.update!(manager: manager)}
resolved_issues.each{|i| i.update!(status: 'resolved')}

if manager.issues.count == 0
  manager.issues.create(title: Faker::Lorem.sentence,
                        description: Faker::Lorem.paragraph)
end