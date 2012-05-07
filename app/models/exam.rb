class Exam < ActiveRecord::Base
  has_many :participations
  belongs_to :user

  has_attached_file :data

  # Add the users as participants
  def add_users(users)
    users.map { |u| participations.create(user: u) }
  end

  # An exam is in progress if if start_time < Time.now < end_time
  # and it is not locked
  def in_progress?
    Time.now.utc.between?(start_time,end_time) && !locked?
  end
end
