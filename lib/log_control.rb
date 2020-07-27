class LogControl
  def self.write_keys(filename)
    InjectedKeys.log("./main/#{filename}")
  end

  def self.upload
    return unless Device::Network.connected?

    if layout_exists?
      Device::Display.print_bitmap('./shared/send_log.bmp')
    else
      Device::Display.clear
      I18n.pt(:admin_logs_upload_check)
      Device::Display.print(I18n.t(:admin_logs_upload_cancel), 2)
      Device::Display.print("", 3)
    end

    file = self.get_log_file
    LogsMenu.send_file(file) if File.exists?("./main/#{file}")
    self.purge
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
  def self.get_log_file
    time = (Time.now - (24 * 60 * 60))
    "#{"%d-%02d-%02d" % [time.year, time.month, time.day]}.log"
  end

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
