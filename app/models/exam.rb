class Exam < ActiveRecord::Base

  has_many :participations
  belongs_to :user

  has_attached_file :data

end
