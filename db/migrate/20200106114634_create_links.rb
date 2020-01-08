class CreateLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :links do |t|
      t.string :name
      t.text :url
      t.belongs_to :linkable, polymorphic: true
      t.timestamps
    end
  end
end
