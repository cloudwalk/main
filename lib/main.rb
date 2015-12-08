require 'simplehttp'

class Main < Device
  include Device::Helper
  def self.call
    Cloudwalk.boot
    Device::Display.clear

    Device.app_loop do
      time = Time.now
      Device::Display.print_bitmap("./shared/walk.bmp",0,0)
      puts ""
      Device::Display.print("#{rjust(time.day.to_s, 2, "0")}/#{rjust(time.month.to_s, 2, "0")}/#{time.year} #{rjust(time.hour.to_s, 2, "0")}:#{rjust(time.min.to_s, 2, "0")}", 6, 0)
      case getc(2000)
      when Device::IO::ENTER
        Cloudwalk.start
      when Device::IO::F1
        AdminConfiguration.perform
      when Device::IO::F2
        break
      end
    end
  end

  def self.version
    "0.1.0"
  end
end

