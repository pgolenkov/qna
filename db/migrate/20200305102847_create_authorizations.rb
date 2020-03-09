class CreateAuthorizations < ActiveRecord::Migration[5.2]
  def change
    create_table :authorizations do |t|
      t.references :user, foreign_key: true, null: false
      t.string :provider, null: false
      t.string :uid, null: false
      t.timestamps
    end

    add_index :authorizations, [:provider, :uid], unique: true
  end
end
