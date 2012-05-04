class AddAttachmentAnswersToParticipations < ActiveRecord::Migration
  def self.up
    add_column :participations, :answers_file_name, :string
    add_column :participations, :answers_content_type, :string
    add_column :participations, :answers_file_size, :integer
    add_column :participations, :answers_updated_at, :datetime
  end

  def self.down
    remove_column :participations, :answers_file_name
    remove_column :participations, :answers_content_type
    remove_column :participations, :answers_file_size
    remove_column :participations, :answers_updated_at
  end
end
