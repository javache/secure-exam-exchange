class Exam < ActiveRecord::Base

  has_many :participations

  belongs_to :user

end
