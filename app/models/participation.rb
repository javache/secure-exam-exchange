require 'digest'

class Participation < ActiveRecord::Base
  belongs_to :user
  belongs_to :exam

  has_attached_file :answers
  validate :sane_answers_zip
  has_attached_file :results
  validate :sane_results_zip

  def sane_answers_zip
    return unless answers.present?
    verify_files_present :answers, answers, %w{.asc .enc}
  end

  def sane_results_zip
    return unless results.present?
    verify_files_present :results, results, %w{.asc .enc}
  end

  # Validator method to check if the zip file is sane
  def verify_files_present(label, attachment, req_files)
    if File.extname(answers.original_filename) != ".zip" then
      errors.add(label, "needs to be a zip file")
      return
    end

    # The queued_for_write stuff is necessary, because the file hasn't been
    # saved at this point. Blame paperclip.
    path = attachment.path
    path = attachment.queued_for_write[:original].path unless File.exists?(path)

    # Check the contents of the zip file in path.
    files = Zippy.list(path)
    file_name = File.basename(attachment.original_filename)
    file_name = file_name.chomp(File.extname(file_name))

    # TO FIX: does not work with filenames containing spaces
    # and probably other 'unsafe' characters
    req_files.each do |ext|
      if !files.include?(file_name + ext)
        errors.add(label, "needs #{file_name}#{ext}")
      end
    end
  end


  def generate_upload_proof(user)
    hash = Digest::SHA512.file(answers.path).hexdigest

    time = Time.now.utc
    name = user.name

    file_name = "#{name}-#{time}"
    proof = "Student: #{name}\nTime: #{time}\nAnswers: #{hash}\n\n"
    tmp_dir = Dir.tmpdir
    tmp_file_path = File.join(tmp_dir, file_name)

    # create signature for proof
    stdin, stdout, wait_thread = Open3.popen2("gpg --clearsign --digest-algo SHA512")
    stdin.write(proof)
    stdin.close
    exit_status = wait_thread.value

    Zippy.create(tmp_file_path) do |zip|
      zip['proof.txt'] = stdout.read
      zip['exam.zip'] = open(exam.data.path)
    end

    yield tmp_file_path

    File.unlink tmp_file_path
  end

  def answers_base_name
    base_name = File.basename(answers_file_name)
    base_name.chomp(File.extname(base_name))
  end

  def results_base_name
    base_name = File.basename(answers_file_name)
    base_name.chomp(File.extname(base_name))
  end
end
