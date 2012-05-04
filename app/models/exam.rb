class Exam < ActiveRecord::Base
  has_many :participations
  belongs_to :user

  has_attached_file :data

  # Add the users as participants
  def add_users(users)
    users.map { |u| participations.create(user: u) }
  end
end
