class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true, null: false
      t.belongs_to :subscribable, polymorphic: true
      t.timestamps
    end
    add_index :subscriptions, [:user_id, :subscribable_id, :subscribable_type], unique: true, name: 'unique_index_on_user_id_for_subscribable'
  end
end
