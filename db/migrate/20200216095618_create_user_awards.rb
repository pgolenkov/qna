class CreateUserAwards < ActiveRecord::Migration[5.2]
  def change
    create_table :user_awards do |t|
      t.references :user, foreign_key: true
      t.references :award, foreign_key: true
      t.timestamps
    end
  end
end
