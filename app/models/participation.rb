class Participation < ActiveRecord::Base

  belongs_to :user
  belongs_to :exam

  has_attached_file :answers
  has_attached_file :results

end
