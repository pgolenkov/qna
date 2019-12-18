class AddBestColumnToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :answers, :best, :boolean, default: false, null: false
    add_index :answers, :question_id, unique: true, name: 'unique_index_on_question_id_for_best_answers', where: "(best = true)"
  end
end
