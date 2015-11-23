require 'simplehttp'

class Main < Device
  include Device::Helper
  def self.call
    Cloudwalk.boot
    Device::Display.clear

    Device.app_loop do
      time = Time.now
      Device::Display.print_bitmap("./shared/walk.bmp",0,0)
      Device::Display.print(" #{time.day}/#{time.month}/#{time.year}   #{time.hour}:#{rjust(time.min, 2, "0")}", 6, 0)
      puts ""
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
