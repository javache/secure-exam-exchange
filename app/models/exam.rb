class Exam < ActiveRecord::Base
  has_many :participations
  belongs_to :user

  has_attached_file :data
  validate :sane_exam_zip

  # Add the users as participants
  def add_users(users)
    users.map { |u| participations.find_or_create_by_user_id(u.id) }
  end

  # An exam is in progress if if start_time < Time.now < end_time
  # and it is not locked
  def in_progress?
    Time.now.utc.between?(start_time,end_time) && !locked?
  end

  # Validator method to check if the zip file is sane
  def sane_exam_zip
    puts data.path
    if File.extname(data_file_name) != ".zip" then
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
