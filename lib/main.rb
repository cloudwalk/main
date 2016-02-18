require 'funky-simplehttp'

class Main < Device
  include Device::Helper
  def self.call
    Cloudwalk.boot
    Device::Display.clear

    Device.app_loop do
      Device::Display.print_bitmap("./shared/walk.bmp",0,0)
      Device::Display.print(I18n.t(:time, :time => Time.now), 6, 0)
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
    "1.0.4"
  end
end

