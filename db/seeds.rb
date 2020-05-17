# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.new(email: 'admin@email.com', admin: true, password: '123456', password_confirmation: '123456')
admin.skip_confirmation!
admin.save!

user = User.new(email: 'user@email.com', admin: true, password: '123456', password_confirmation: '123456')
user.skip_confirmation!
user.save!

questions = Question.create!([
  { title: 'Вопрос для примера 1', body: 'Сам текст вопроса для примера 1', user: admin },
  { title: 'Вопрос для примера 2', body: 'Сам текст вопроса для примера 2', user: user }
])

answers = questions.map do |question|
  question.answers.create!([
    { body: 'Ответ 1', user: admin },
    { body: 'Ответ 2', user: user }
  ])
end
