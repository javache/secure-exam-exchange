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
    (start_time <=> Time.now) == -1 and
    (Time.now <=> end_time) == -1 and
    !locked
  end
end
