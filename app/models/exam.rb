class Exam < ActiveRecord::Base
  has_many :participations
  belongs_to :user

  validates :name, :presence => true
  validate :start_before_end

  has_attached_file :data
  validates_attachment_presence :data
  validate :sane_exam_zip

  def edit_users(updated_users)
    # Find the current users
    users = participations.collect(&:user)

    # Remove the users which are not in the list anymore
    (users - updated_users).each do |user|
      participations.find_by_user_id(user.id).delete
    end

    # Add the users which weren't in the list yet
    (updated_users - users).each do |user|
      participations.find_or_create_by_user_id(user.id)
    end
  end

  # Check if a certain user can edit this exam
  def can_edit?(owner)
    user == owner
  end

  # Check if a certain user is a participant of this exam
  def participant?(user)
    participations.any? { |p| p.user == user }
  end

  # An exam is in progress if if start_time < Time.now < end_time
  # and it is not locked
  def in_progress?
    Time.now.utc.between?(start_time,end_time) && !locked?
  end

  def start_before_end
    if start_time >= end_time then
      errors.add(:end_time, "can't be before start time")
    end
  end

  # Validator method to check if the zip file is sane
  def sane_exam_zip
    if File.extname(data_file_name || "") != ".zip" then
      errors.add(:data, "needs to be a zip file")
      return
    end

    # The queued_for_write stuff is necessary, because the file hasn't been
    # saved at this point. Blame paperclip.
    path = data.path
    path = data.queued_for_write[:original].path unless File.exists?(path)

    # Check the contents of the zip file in path.
    files = Zippy.list(path)
    file_name = File.basename(data_file_name)
    file_name = file_name.chomp(File.extname(file_name))
    if !files.include?(file_name) or !files.include?(file_name + ".sig") then
      errors.add(:data, "needs #{file_name} and #{file_name}.sig")
    end
  end
end
