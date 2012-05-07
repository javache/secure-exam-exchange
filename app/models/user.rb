class User < ActiveRecord::Base
  has_many :participations

  # TODO: we might want to rename tests to something
  has_many :exams, :through => :participations
  has_many :tests, :class_name => Exam


end
