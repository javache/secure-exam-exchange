class User < ActiveRecord::Base
  has_many :participations
  has_many :exams
end
