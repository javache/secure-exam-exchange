class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.string :name
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :locked

      t.integer :user_id

      t.timestamps
    end
  end
end
