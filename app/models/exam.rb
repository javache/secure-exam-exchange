require 'fileutils'
require 'open3'
require 'tmpdir'

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
    Time.now.between?(start_time, end_time) && !locked?
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
    file_name = exam_base_name

    # TO FIX: does not work with filenames containing spaces
    # and probably other 'unsafe' characters
    if !files.include?(file_name + ".asc")
      errors.add(:data, "needs #{file_name}.asc")
    end

    if !files.include?(file_name) and !files.include?(enc_exam_base_name) then
      errors.add(:data, "needs #{file_name} or #{file_name}.enc")
    end
  end

  # Unlock an exam with a password
  def unlock(password)
    # Find the encrypted file
    enc_file_name = enc_exam_base_name
    if !Zippy.list(data.path).include? enc_file_name then
      errors.add(:data, "is not locked")
      return
    end

    # Create a temporary file and write the encrypted file there
    enc_file_path = File.join(Dir.tmpdir, enc_file_name)
    File.open(enc_file_path, 'wb') do |f|
      f.write(Zippy.read(data.path, enc_file_name))
    end
    puts "Wrote #{enc_file_path}"

    # Create a temporary file for the unencrypted file
    file_name = exam_base_name
    file_path = File.join(Dir.tmpdir, file_name)
    stdin, stdout, wait_thread = Open3.popen2(
      "openssl enc -aes-256-cbc -d -in '#{enc_file_path}' " +
      "-out '#{file_path}' -pass stdin")
    stdin.write(password)
    stdin.close
    exit_status = wait_thread.value

    # DEBUG
    puts "openssl output: #{stdout.read}"

    # Check that encryption worked
    if exit_status != 0 then
      errors.add(:data, "does not match the given password")
      return
    end

    # Remove encrypted file, add unencrypted file
    Zippy.open(data.path) do |zip|
      zip.delete(enc_file_name)
      zip[file_name] = File.binread(file_path)
    end
  end

  def locked?
    Zippy.list(data.path).include? enc_exam_base_name
  end

  private

  def exam_base_name
    base_name = File.basename(data_file_name)
    base_name.chomp(File.extname(base_name))
  end

  def enc_exam_base_name
    exam_base_name + ".enc"
  end
end
