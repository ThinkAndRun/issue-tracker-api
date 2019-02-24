# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

regular_user = User.create_with(name: 'Regular User',
                                password: 'password',
                                password_confirmation: 'password')
                   .find_or_create_by(email: 'regular@example.com')

manager = User.create_with(name: 'Manager',
                           password: 'password',
                           password_confirmation: 'password',
                           manager: true)
              .find_or_create_by(email: 'manager@example.com')
