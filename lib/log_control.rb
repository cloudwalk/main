class LogControl
  def self.delete_old_logs
    dirs = Dir.entries("./main").select { |p| p.include?(".log") }
    date_today = self.get_date_today
    dirs.each do |file|
      if self.compare_dates(file[0..(file.index('.') - 1)], date_today) > 1296000
        File.delete("./main/#{file}")
      end
    end
  end

  def self.write_keys_on_log
    self.write_keys!
  end

  private

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

  def self.write_keys!
    time = Time.now
    logname = "./main/#{"%d-%02d-%02d" % [time.year, time.month, time.day]}.log"
    if !File.exists?(logname)
      InjectedKeys.write_injected_keys_on_log
    end
  end
end
