class LogControl
  def initialize(filename)
    @filename = filename
  end

  def write_keys_on_log
    write_keys! unless log_ready?
  end

  def self.upload_log_file
    LogsMenu.send_file(self.get_log_file)
  end

  def self.delete_old_logs
    dirs = Dir.entries("./main").select { |p| p.include?(".log") }
    date_today = self.get_date_today
    dirs.each do |file|
      if self.compare_dates(file[0..(file.index('.') - 1)], date_today) > 1296000
        File.delete("./main/#{file}")
      end
    end
  end

  private

  def write_keys!
    InjectedKeys.write_injected_keys_on_log(@filename)
  end

  def log_ready?
    File.read(@filename).each_line do |line|
      return true if line[0..2] == "[K]"
    end
    false
  end

  def self.get_log_file
    time = Time.now
    "#{"%d-%02d-%02d" % [time.year, time.month, time.day]}.log"
  end

  def self.compare_dates(text1, text2)
    date = text1.match(/([0-9]+)-([0-9]+)-([0-9]+)/)
    greaterdate = text2.match(/([0-9]+)-([0-9]+)-([0-9]+)/)
    unless date || greaterdate
      return nil
    end
    (Time.local(greaterdate[1].to_i, greaterdate[2].to_i, greaterdate[3].to_i) - Time.local(date[1].to_i, date[2].to_i, date[3].to_i)).to_i
  end

  def self.get_date_today
    time = Time.now
    "%d-%02d-%02d %02d:%02d:%02d:%06d" % [time.year, time.month, time.day, time.hour, time.min, time.sec, time.usec]
  end
end
