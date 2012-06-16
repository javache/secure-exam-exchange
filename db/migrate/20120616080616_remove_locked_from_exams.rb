class RemoveLockedFromExams < ActiveRecord::Migration
  def up
    remove_column :exams, :locked
  end

  def down
    add_column :exams, :locked
  end
end
