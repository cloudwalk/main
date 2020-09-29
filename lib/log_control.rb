class LogControl
  def self.write_keys(filename)
    InjectedKeys.log("./main/#{filename}")
  end

  def self.upload
    return unless Device::Network.connected?

    layout
    Dir.entries("./main").select { |e| e.include?(".log") }.each do |log|
      LogsMenu.send_file(log)
    end
  end

  def self.purge
    dirs = Dir.entries("./main").select { |p| p.include?(".log") }
    date_today = self.get_date_today
    dirs.each do |file|
      if self.compare_dates(file[0..(file.index('.') - 1)], date_today) >= 604800
        File.delete("./main/#{file}")
      end
    end
  end

  def self.layout
    Device::Display.print_bitmap('./shared/send_log.bmp')
  end

  private
  def self.compare_dates(text1, text2)
    date = text1.match(/([0-9]+)-([0-9]+)-([0-9]+)/)
    greaterdate = text2.match(/([0-9]+)-([0-9]+)-([0-9]+)/)
    unless date || greaterdate
      return 0
    end
    (Time.local(greaterdate[1].to_i, greaterdate[2].to_i, greaterdate[3].to_i) - Time.local(date[1].to_i, date[2].to_i, date[3].to_i)).to_i
  end

  def self.get_date_today
    time = Time.now
    "%d-%02d-%02d %02d:%02d:%02d:%06d" % [time.year, time.month, time.day, time.hour, time.min, time.sec, time.usec]
  end
end
