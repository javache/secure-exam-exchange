class User < ActiveRecord::Base
  has_many :participations
  has_many :exams_participated, :through => :participations, :source => :exam
  has_many :exams_created, :class_name => Exam
end
