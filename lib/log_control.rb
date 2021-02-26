class LogControl
  def self.write_keys(filename)
    InjectedKeys.log("./main/#{filename}")
  end

  def self.upload
    return unless Device::Network.connected?

    layout
    files = Dir.entries("./main").select { |e| e.include?(".log") }
    ret = files.inject(true) do |ret, log|
      if send_by_parts?(log)
        ret && send_by_parts(log)
      else
        ret && LogsMenu.send_file(log)
      end
    end

    if ret
      Device::Display.print_bitmap('./shared/send_log_sucess.bmp')
    else
      Device::Display.print_bitmap('./shared/send_log_fail.bmp')
    end
    getc(3000)
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

  def self.send_by_parts?(log)
    File.size("./main/#{log}") > 51200
  end

  def self.send_by_parts(log)
    old_name, path_name = ["./main/#{log}", "./main/#{log}"]
    if log_from_today?(log)
      path_name = "./main/#{log.split('.')[0]}_new.log"
      File.delete(path_name) if File.exists?(path_name)
      File.rename(old_name, path_name)
    else
      path_name = "./main/#{log}"
    end

    part = 1
    result = true
    File.open(path_name) do |file|
      while buffer = file.read(1024 * 50)
        filename = "./main/#{log.split('.')[0]}_part_#{part}.log"
        File.open(filename, 'w') { |f| f.write(buffer) }
        if File.exists?(filename)
          newfile = filename[7..-1]
          unless LogsMenu.send_file(newfile)
            File.delete(filename) if File.exists?(filename)
            result = false
            break
          end
          part+=1
        else
          result = false
          break
        end
      end
    end
    if result
      File.delete(path_name) if File.exists?(path_name)
      File.delete(old_name) if File.exists?(old_name)
    end
    result
  rescue => e
    ContextLog.exception(e, e.backtrace, 'send log by parts')
    false
  end

  def self.log_from_today?(log)
    log.split('.')[0] == get_date_today.split(' ')[0]
  end
end
