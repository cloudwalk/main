class LogControl
  def initialize(filename)
    @filename = filename
  end

  def write_keys
    InjectedKeys::log(@filename)
  end

  def self.enabled?
    Device::ParamsDat.file["log_upload_enabled"] == "1"
  end

  def self.upload
    return unless self.enabled? && Device::Network.connected?

    Device::Display.clear
    I18n.pt(:admin_logs_upload_check)
    Device::Display.print(I18n.t(:admin_logs_upload_cancel), 2)
    Device::Display.print("", 3)
    key = Device::IO::KEY_TIMEOUT

    5.times do |i|
      Device::Display.print((10 - i).to_s, 5, 11)
      key = getc(1000)
      break if key != Device::IO::KEY_TIMEOUT
    end
    if key != Device::IO::CANCEL
      LogsMenu.send_file(self.get_log_file)
    end
  end

  def self.purge
    dirs = Dir.entries("./main").select { |p| p.include?(".log") }
    date_today = self.get_date_today
    dirs.each do |file|
      if self.compare_dates(file[0..(file.index('.') - 1)], date_today) > 1296000
        File.delete("./main/#{file}")
      end
    end
  end

  private
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
